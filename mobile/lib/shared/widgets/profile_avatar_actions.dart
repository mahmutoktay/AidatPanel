import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p; // ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/presentation/providers/profile_notifier.dart';
import '../../l10n/strings.g.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'premium_bottom_sheet.dart';
import 'image_source_sheet.dart';
import 'toast_overlay.dart';

/// Opens the custom profile photo editor bottom sheet.
Future<void> handleProfileAvatarTap(BuildContext context, WidgetRef ref) async {
  final user = ref.read(authStateProvider).user;
  if (user == null) return;

  await PremiumBottomSheetScaffold.show<void>(
    context: context,
    builder: (context) => const ProfilePhotoEditSheet(),
  );
}

/// A custom, premium profile photo edit bottom sheet.
class ProfilePhotoEditSheet extends ConsumerStatefulWidget {
  const ProfilePhotoEditSheet({super.key});

  @override
  ConsumerState<ProfilePhotoEditSheet> createState() =>
      _ProfilePhotoEditSheetState();
}

class _ProfilePhotoEditSheetState extends ConsumerState<ProfilePhotoEditSheet> {
  /// Circle diameter — the actual crop region is a square of this size.
  static const double _kCircleDiameter = 220.0;

  /// Visual viewport height equals the circle diameter.
  static const double _kViewportH = _kCircleDiameter;

  final TransformationController _transformationController =
      TransformationController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  ui.Image? _imageInfo;
  bool _isProcessing = false;
  bool _isGif = false;
  double _scaleToCover = 1.0;
  double _viewportWidth = _kCircleDiameter;

  @override
  void dispose() {
    _transformationController.dispose();
    _cleanupTempFile();
    super.dispose();
  }

  Future<void> _cleanupTempFile() async {
    if (_imageFile != null) {
      try {
        if (await _imageFile!.exists()) {
          await _imageFile!.delete();
        }
      } catch (_) {}
    }
  }

  Future<void> _loadImageInfo(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(bytes, (ui.Image img) {
        completer.complete(img);
      });
      final decodedInfo = await completer.future;

      if (!mounted) return;

      final double imgW = decodedInfo.width.toDouble();
      final double imgH = decodedInfo.height.toDouble();

      // Scale to cover the circle diameter (square region).
      final scale = math.max(_kCircleDiameter / imgW, _kCircleDiameter / imgH);
      final childW = imgW * scale;
      final childH = imgH * scale;

      // Center the image inside the viewport.
      final tx = (_viewportWidth - childW) / 2.0;
      final ty = (_kViewportH - childH) / 2.0;

      final newMatrix = Matrix4.identity();
      newMatrix.storage[0] = 1.0;
      newMatrix.storage[5] = 1.0;
      newMatrix.storage[10] = 1.0;
      newMatrix.storage[12] = tx;
      newMatrix.storage[13] = ty;
      newMatrix.storage[15] = 1.0;

      setState(() {
        _imageFile = file;
        _imageInfo = decodedInfo;
        _scaleToCover = scale;
        _transformationController.value = newMatrix;
        _isProcessing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ref
            .read(toastProvider.notifier)
            .show(
              context.t.features.profile.avatarPhotoLoadError,
              type: ToastType.error,
            );
      }
    }
  }

  /// Returns true when the file extension looks like a GIF.
  bool _isGifFile(String filePath) {
    return p.extension(filePath).toLowerCase() == '.gif';
  }

  Future<void> _handlePickedFile(XFile picked) async {
    setState(() {
      _isProcessing = true;
    });

    final t = context.t.features.profile;

    try {
      // Clean up previous temp file if exists
      await _cleanupTempFile();

      final isGif = _isGifFile(picked.path);

      if (isGif) {
        // GIF: copy as-is to temp without re-encoding to preserve animation
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.gif',
        );
        await File(picked.path).copy(tempFile.path);

        _isGif = true;
        await _loadImageInfo(tempFile);
      } else {
        // Static image: bake EXIF orientation and re-encode as JPG
        final bytes = await File(picked.path).readAsBytes();

        final original = img.decodeImage(bytes);
        if (original == null) {
          throw Exception(t.avatarDecodeError);
        }

        final oriented = img.bakeOrientation(original);

        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/oriented_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await tempFile.writeAsBytes(img.encodeJpg(oriented, quality: 90));

        _isGif = false;
        await _loadImageInfo(tempFile);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ref
            .read(toastProvider.notifier)
            .show(
              context.t.features.profile.avatarPhotoProcessError,
              type: ToastType.error,
            );
      }
    }
  }

  Future<void> _pickFromSource() async {
    if (_isProcessing) return;
    final source = await showImageSourceSheet(context);
    if (source == null || !mounted) return;
    if (source == ImageSource.camera) {
      await _pickFromCamera();
    } else {
      await _pickFromGallery();
    }
  }

  Future<void> _pickFromCamera() async {
    if (_isProcessing) return;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (picked != null) {
        await _handlePickedFile(picked);
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(
              context.t.features.profile.avatarCameraError,
              type: ToastType.error,
            );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    try {
      // pickMedia allows selecting GIFs (pickImage filters them out)
      final picked = await _picker.pickMedia();
      if (picked != null) {
        // Only accept image types (reject video etc.)
        final ext = p.extension(picked.path).toLowerCase();
        const allowedExts = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic', '.heif'};
        if (!allowedExts.contains(ext)) {
          if (mounted) {
            ref
                .read(toastProvider.notifier)
                .show(
                  context.t.features.profile.avatarUnsupportedFormat,
                  type: ToastType.error,
                );
          }
          return;
        }
        await _handlePickedFile(picked);
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(
              context.t.features.profile.avatarGalleryError,
              type: ToastType.error,
            );
      }
    }
  }

  Future<void> _saveImage() async {
    if (_imageFile == null || _imageInfo == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final t = context.t;

    try {
      String uploadPath;

      if (_isGif) {
        // GIF: upload original file as-is (no crop/re-encode to preserve animation)
        uploadPath = _imageFile!.path;
      } else {
        // Static image: crop and re-encode as JPG
        final bytes = await _imageFile!.readAsBytes();
        final original = img.decodeImage(bytes);
        if (original == null) {
          throw Exception(t.features.profile.avatarDecodeError);
        }

        final matrix = _transformationController.value;
        final s = matrix.storage[0];
        final tx = matrix.storage[12];
        final ty = matrix.storage[13];

        final double totalScale = s * _scaleToCover;
        final double cropX =
            (((_viewportWidth - _kCircleDiameter) / 2.0) - tx) / totalScale;
        final double cropY = -ty / totalScale;
        final double cropW = _kCircleDiameter / totalScale;
        final double cropH = _kCircleDiameter / totalScale;

        final double cropSize = math.min(cropW, cropH);

        final int finalX = cropX
            .clamp(0.0, (original.width - cropSize).toDouble())
            .toInt();
        final int finalY = cropY
            .clamp(0.0, (original.height - cropSize).toDouble())
            .toInt();
        final int finalSize = cropSize
            .clamp(1.0, math.min(original.width, original.height).toDouble())
            .toInt();

        final cropped = img.copyCrop(
          original,
          x: finalX,
          y: finalY,
          width: finalSize,
          height: finalSize,
        );

        final croppedBytes = Uint8List.fromList(
          img.encodeJpg(cropped, quality: 85),
        );

        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/cropped_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await tempFile.writeAsBytes(croppedBytes);
        uploadPath = tempFile.path;
      }

      final success = await ref
          .read(profileNotifierProvider.notifier)
          .uploadAvatar(uploadPath);

      // Clean up temp file (for non-GIF, the cropped temp file; for GIF, _cleanupTempFile handles it)
      if (!_isGif) {
        final tempFile = File(uploadPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (success) {
        ref
            .read(toastProvider.notifier)
            .show(t.features.profile.photoSaved, type: ToastType.success);
        Navigator.pop(context);
      } else {
        final error = ref.read(profileNotifierProvider).error;
        ref
            .read(toastProvider.notifier)
            .show(
              error ?? t.features.expenses.receiptPickFailed,
              type: ToastType.error,
            );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ref
            .read(toastProvider.notifier)
            .show(t.features.profile.avatarSaveError, type: ToastType.error);
      }
    }
  }

  Future<void> _removeImage() async {
    if (_isProcessing) return;

    final user = ref.read(authStateProvider).user;
    final hasPhoto =
        user?.profilePicture != null && user!.profilePicture!.isNotEmpty;

    if (!hasPhoto) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final t = context.t;
    final success = await ref
        .read(profileNotifierProvider.notifier)
        .deleteAvatar();

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      ref
          .read(toastProvider.notifier)
          .show(t.features.profile.photoRemoved, type: ToastType.info);
      Navigator.pop(context);
    } else {
      final error = ref.read(profileNotifierProvider).error;
      ref
          .read(toastProvider.notifier)
          .show(
            error ?? t.features.expenses.receiptPickFailed,
            type: ToastType.error,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileT = context.t.features.profile;
    final user = ref.watch(authStateProvider.select((state) => state.user));
    final hasPhoto =
        user?.profilePicture != null && user!.profilePicture!.isNotEmpty;
    final avatarUrl = hasPhoto
        ? '${ApiConstants.baseUrl}/uploads/avatars/${user.profilePicture}'
        : null;

    return PremiumBottomSheetScaffold(
      scrollable: false,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingL),
      title: context.t.features.profile.editTitle,
      showCloseButton: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSizes.spacingM),
          _buildCropArea(profileT, avatarUrl: avatarUrl, hasPhoto: hasPhoto),
        ],
      ),
      actions: PremiumSheetActions(
        primaryLabel: profileT.avatarSave,
        onPrimary: _imageFile != null && !_isProcessing ? _saveImage : null,
        primaryLoading: _isProcessing && _imageFile != null,
      ),
    );
  }


  Widget _buildCropArea(
    Translations$features$profile$en profileT, {
    required String? avatarUrl,
    required bool hasPhoto,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportW = constraints.maxWidth;
        _viewportWidth = viewportW;
        final showCrop = _imageFile != null && _imageInfo != null;
        final showServerPhoto = !showCrop && avatarUrl != null && _imageFile == null;

        return GestureDetector(
          onTap: _isProcessing || showCrop
              ? null
              : _pickFromSource,
          child: Container(
            width: viewportW,
            height: _kViewportH,
            decoration: BoxDecoration(
              color: AppColors.isDark
                  ? const Color(0xFF0D1117)
                  : const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // InteractiveViewer (crop mode) — local file picked
                if (showCrop)
                  InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 4.0,
                    boundaryMargin: EdgeInsets.symmetric(
                      horizontal: math.max(
                        0.0,
                        (viewportW - _kCircleDiameter) / 2.0,
                      ),
                    ),
                    clipBehavior: Clip.none,
                    constrained: false,
                    child: SizedBox(
                      width: _imageInfo!.width.toDouble() * _scaleToCover,
                      height: _imageInfo!.height.toDouble() * _scaleToCover,
                      child: Image.file(_imageFile!, fit: BoxFit.fill),
                    ),
                  )
                // Server photo (preview) — centered square matching circle size
                else if (showServerPhoto)
                  Center(
                    child: SizedBox(
                      width: _kCircleDiameter,
                      height: _kCircleDiameter,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl,
                          width: _kCircleDiameter,
                          height: _kCircleDiameter,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(profileT),
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                // Processing
                else if (_isProcessing)
                  Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  )
                // Empty placeholder
                else
                  _buildPlaceholder(profileT),

                // Crop overlay with circular cutout
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(viewportW, _kViewportH),
                    painter: _CircleCropOverlayPainter(
                      circleDiameter: _kCircleDiameter,
                      isDark: AppColors.isDark,
                    ),
                  ),
                ),

                // 🗑️ Remove button — top right when a photo is visible (server or local crop)
                if (showServerPhoto || showCrop)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: AppColors.error.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _isProcessing ? null : _removeImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          child: _isProcessing
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(Translations$features$profile$en profileT) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            child: Icon(
              Icons.add_a_photo_rounded,
              size: 32,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profileT.avatarChooseSource,
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.3),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Premium circle crop overlay with gradient ring
// ─────────────────────────────────────────────
class _CircleCropOverlayPainter extends CustomPainter {
  final double circleDiameter;
  final bool isDark;
  _CircleCropOverlayPainter({
    required this.circleDiameter,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = circleDiameter / 2;

    // Dim overlay outside the circle
    final overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawPath(
      overlayPath,
      Paint()
        ..color = isDark
            ? const Color(0xAA0D1117)
            : const Color(0xAA161B22)
        ..style = PaintingStyle.fill,
    );

    // Gradient ring around the circle
    final ringPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.35),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, ringPaint);

    // Inner subtle glow
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleCropOverlayPainter oldDelegate) =>
      oldDelegate.circleDiameter != circleDiameter ||
      oldDelegate.isDark != isDark;
}
