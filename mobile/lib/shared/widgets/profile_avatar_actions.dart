import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/presentation/providers/profile_notifier.dart';
import '../../l10n/strings.g.dart';
import 'toast_overlay.dart';

/// Opens the custom profile photo editor bottom sheet.
Future<void> handleProfileAvatarTap(BuildContext context, WidgetRef ref) async {
  final user = ref.read(authStateProvider).user;
  if (user == null) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ProfilePhotoEditSheet(),
  );
}

/// A custom, premium profile photo edit bottom sheet.
class ProfilePhotoEditSheet extends ConsumerStatefulWidget {
  const ProfilePhotoEditSheet({super.key});

  @override
  ConsumerState<ProfilePhotoEditSheet> createState() => _ProfilePhotoEditSheetState();
}

class _ProfilePhotoEditSheetState extends ConsumerState<ProfilePhotoEditSheet> {
  /// Circle diameter — the actual crop region is a square of this size.
  static const double _kCircleDiameter = 220.0;
  /// Visual viewport height equals the circle diameter.
  static const double _kViewportH = _kCircleDiameter;

  final TransformationController _transformationController = TransformationController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  ui.Image? _imageInfo;
  bool _isProcessing = false;
  double _scaleToCover = 1.0;
  double _viewportWidth = _kCircleDiameter;

  @override
  void initState() {
    super.initState();
  }

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
        ref.read(toastProvider.notifier).show(
              "Fotoğraf yüklenirken bir hata oluştu.",
              type: ToastType.error,
            );
      }
    }
  }

  Future<void> _handlePickedFile(XFile picked) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Clean up previous temp file if exists
      await _cleanupTempFile();

      // Read original image bytes
      final bytes = await File(picked.path).readAsBytes();
      
      // Decode image
      final original = img.decodeImage(bytes);
      if (original == null) {
        throw Exception("Görsel çözümlenemedi.");
      }

      // Bake EXIF orientation to avoid rotation mismatches in the preview and crop
      final oriented = img.bakeOrientation(original);

      // Save oriented image to a new temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/oriented_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(img.encodeJpg(oriented, quality: 90));

      // Load this oriented temp file
      await _loadImageInfo(tempFile);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ref.read(toastProvider.notifier).show(
              "Fotoğraf işlenirken hata oluştu.",
              type: ToastType.error,
            );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    if (_isProcessing) return;
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        await _handlePickedFile(picked);
      }
    } catch (e) {
      if (mounted) {
        ref.read(toastProvider.notifier).show(
              "Kamera başlatılamadı.",
              type: ToastType.error,
            );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        await _handlePickedFile(picked);
      }
    } catch (e) {
      if (mounted) {
        ref.read(toastProvider.notifier).show(
              "Galeri açılamadı.",
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
      // Read bytes of already oriented image
      final bytes = await _imageFile!.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) {
        throw Exception("Görsel çözümlenemedi.");
      }

      final matrix = _transformationController.value;
      final s = matrix.storage[0];
      final tx = matrix.storage[12];
      final ty = matrix.storage[13];

      // Map coordinates back to original image space using the viewport width and circle diameter.
      // Since the circle is centered in the viewport, the crop area's left edge is at (viewportWidth - circleDiameter) / 2.
      final double totalScale = s * _scaleToCover;
      final double cropX = (((_viewportWidth - _kCircleDiameter) / 2.0) - tx) / totalScale;
      final double cropY = -ty / totalScale;
      final double cropW = _kCircleDiameter / totalScale;
      final double cropH = _kCircleDiameter / totalScale;

      // Force square crop
      final double cropSize = math.min(cropW, cropH);

      // Clamp coordinates to stay within image boundaries
      final int finalX = cropX.clamp(0.0, (original.width - cropSize).toDouble()).toInt();
      final int finalY = cropY.clamp(0.0, (original.height - cropSize).toDouble()).toInt();
      final int finalSize = cropSize.clamp(1.0, math.min(original.width, original.height).toDouble()).toInt();

      final cropped = img.copyCrop(
        original,
        x: finalX,
        y: finalY,
        width: finalSize,
        height: finalSize,
      );

      final croppedBytes = Uint8List.fromList(img.encodeJpg(cropped, quality: 85));

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/cropped_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(croppedBytes);

      final success = await ref
          .read(profileNotifierProvider.notifier)
          .uploadAvatar(tempFile.path);

      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (success) {
        ref.read(toastProvider.notifier).show(
              t.features.profile.photoSaved,
              type: ToastType.success,
            );
        Navigator.pop(context);
      } else {
        final error = ref.read(profileNotifierProvider).error;
        ref.read(toastProvider.notifier).show(
              error ?? t.features.expenses.receiptPickFailed,
              type: ToastType.error,
            );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ref.read(toastProvider.notifier).show(
              "Fotoğraf kaydedilirken hata oluştu: ${e.toString()}",
              type: ToastType.error,
            );
      }
    }
  }

  Future<void> _removeImage() async {
    if (_isProcessing) return;

    final user = ref.read(authStateProvider).user;
    final hasPhoto = user?.profilePicture != null && user!.profilePicture!.isNotEmpty;

    if (!hasPhoto) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final t = context.t;
    final success = await ref.read(profileNotifierProvider.notifier).deleteAvatar();

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      ref.read(toastProvider.notifier).show(
            t.features.profile.photoRemoved,
            type: ToastType.info,
          );
      Navigator.pop(context);
    } else {
      final error = ref.read(profileNotifierProvider).error;
      ref.read(toastProvider.notifier).show(
            error ?? t.features.expenses.receiptPickFailed,
            type: ToastType.error,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final hasPhoto = user?.profilePicture != null && user!.profilePicture!.isNotEmpty;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Crop area (full-width rectangle, circle guide centered) ──
          LayoutBuilder(
            builder: (context, constraints) {
              final viewportW = constraints.maxWidth;
              _viewportWidth = viewportW;
              return Container(
                width: viewportW,
                height: _kViewportH,
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    if (_imageFile != null && _imageInfo != null)
                      InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 1.0,
                        maxScale: 4.0,
                        boundaryMargin: EdgeInsets.symmetric(
                          horizontal: math.max(0.0, (viewportW - _kCircleDiameter) / 2.0),
                        ),
                        clipBehavior: Clip.none,
                        constrained: false,
                        child: SizedBox(
                          width: _imageInfo!.width.toDouble() * _scaleToCover,
                          height: _imageInfo!.height.toDouble() * _scaleToCover,
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.fill,
                          ),
                        ),
                      )
                    else if (_isProcessing)
                      const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white38,
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),

                    // Semi-transparent overlay with circular cutout
                    IgnorePointer(
                      child: CustomPaint(
                        size: Size(viewportW, _kViewportH),
                        painter: _CircleCropOverlayPainter(
                          circleDiameter: _kCircleDiameter,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Action row: Camera · Gallery ──
          Row(
            children: [
              Expanded(
                child: _SourceButton(
                  icon: Icons.camera_alt_outlined,
                  label: "Kamera",
                  onTap: _isProcessing ? null : _pickFromCamera,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SourceButton(
                  icon: Icons.photo_library_outlined,
                  label: "Galeri",
                  onTap: _isProcessing ? null : _pickFromGallery,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Save button ──
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeightSecondary,
            child: ElevatedButton(
              onPressed: _imageFile != null && !_isProcessing ? _saveImage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.25),
                disabledForegroundColor: Colors.white60,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                ),
                elevation: 0,
              ),
              child: _isProcessing && _imageFile != null
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text("Kaydet", style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ),

          // ── Remove photo (subtle text link) ──
          if (hasPhoto) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: !_isProcessing ? _removeImage : null,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
              ),
              child: _isProcessing && _imageFile == null
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : const Text("Fotoğrafı Kaldır"),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Compact source-pick button (Camera / Gallery)
// ─────────────────────────────────────────────
class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fill,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Circle crop overlay — wide rectangle with
// a centered circular cutout. The area outside
// the circle is semi-transparent so the user
// sees the image bleeding through softly.
// ─────────────────────────────────────────────
class _CircleCropOverlayPainter extends CustomPainter {
  final double circleDiameter;
  _CircleCropOverlayPainter({required this.circleDiameter});

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
        ..color = const Color(0x80161B22) // 50 % overlay — lets the image show through
        ..style = PaintingStyle.fill,
    );

    // Subtle white ring around the circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleCropOverlayPainter oldDelegate) =>
      oldDelegate.circleDiameter != circleDiameter;
}
