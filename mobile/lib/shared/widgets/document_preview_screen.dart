import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../l10n/strings.g.dart';
import '../theme/dashboard_screen_style.dart';
import 'dashboard_secondary_scaffold.dart';

/// Tam ekran belge önizlemesi — dekont, makbuz ve diğer dosyalar için ortak ekran.
class DocumentPreviewScreen extends StatefulWidget {
  const DocumentPreviewScreen({
    super.key,
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    this.onShare,
    this.onDownload,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final Future<void> Function()? onShare;
  final VoidCallback? onDownload;

  static Future<void> open(
    BuildContext context, {
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    Future<void> Function()? onShare,
    VoidCallback? onDownload,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => DocumentPreviewScreen(
          bytes: bytes,
          fileName: fileName,
          mimeType: mimeType,
          onShare: onShare,
          onDownload: onDownload,
        ),
      ),
    );
  }

  static bool isImageMime(String mimeType, String fileName) {
    if (mimeType.startsWith('image/')) return true;
    final ext = fileName.split('.').last.toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'webp';
  }

  static bool isPdfMime(String mimeType, String fileName) {
    if (mimeType == 'application/pdf') return true;
    return fileName.toLowerCase().endsWith('.pdf');
  }

  static String resolveMimeType(String mimeType, String fileName) {
    if (mimeType.isNotEmpty) return mimeType;
    if (isPdfMime('', fileName)) return 'application/pdf';
    if (isImageMime('', fileName)) {
      final ext = fileName.split('.').last.toLowerCase();
      if (ext == 'png') return 'image/png';
      return 'image/jpeg';
    }
    return 'application/octet-stream';
  }

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  PdfControllerPinch? _pdfController;
  bool _pdfLoading = false;
  bool _pdfFailed = false;
  bool _sharing = false;

  bool get _isImage =>
      DocumentPreviewScreen.isImageMime(widget.mimeType, widget.fileName);

  bool get _isPdf =>
      DocumentPreviewScreen.isPdfMime(widget.mimeType, widget.fileName);

  @override
  void initState() {
    super.initState();
    if (_isPdf) {
      _pdfLoading = true;
      _openPdf();
    }
  }

  Future<void> _openPdf() async {
    try {
      final controller = PdfControllerPinch(
        document: PdfDocument.openData(widget.bytes),
      );
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _pdfController = controller;
        _pdfLoading = false;
        _pdfFailed = false;
      });
    } on PlatformException catch (e) {
      debugPrint('[document-preview] platform: ${e.code} ${e.message}');
      if (mounted) {
        setState(() {
          _pdfLoading = false;
          _pdfFailed = true;
        });
      }
    } catch (e) {
      debugPrint('[document-preview] open: $e');
      if (mounted) {
        setState(() {
          _pdfLoading = false;
          _pdfFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _handleShare() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      if (widget.onShare != null) {
        await widget.onShare!();
        return;
      }
      final ext = _isPdf ? 'pdf' : 'jpg';
      final mime = DocumentPreviewScreen.resolveMimeType(
        widget.mimeType,
        widget.fileName,
      );
      final file = XFile.fromData(
        widget.bytes,
        mimeType: mime,
        name: widget.fileName.isNotEmpty ? widget.fileName : 'document.$ext',
      );
      await SharePlus.instance.share(ShareParams(files: [file]));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Widget _buildActionBar(BuildContext context) {
    final t = context.t.common.documentPreview;
    final hasDownload = widget.onDownload != null;

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            if (hasDownload) ...[
              Expanded(
                child: SizedBox(
                  height: ProfileSettingsUi.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: widget.onDownload,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ProfileSettingsUi.ink,
                      side: BorderSide(color: AppColors.borderColor),
                      minimumSize: const Size.fromHeight(
                        ProfileSettingsUi.buttonHeight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ProfileSettingsUi.radiusMd,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 22),
                    label: Text(context.t.common.save),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
            ],
            Expanded(
              flex: hasDownload ? 1 : 2,
              child: SizedBox(
                height: ProfileSettingsUi.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _sharing ? null : _handleShare,
                  style: ProfileSettingsUi.primaryButton,
                  icon: _sharing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share_outlined, size: 22),
                  label: Text(t.share),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.common.documentPreview;

    return DashboardSecondaryScaffold(
      title: t.title,
      bottomNavigationBar: _buildActionBar(context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.dashboardScreenPaddingHorizontal,
          AppSizes.spacingM,
          AppSizes.dashboardScreenPaddingHorizontal,
          AppSizes.spacingM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.fileName,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (_showPinchHint) ...[
              const SizedBox(height: AppSizes.spacingS),
              Text(
                t.pinchHint,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSizes.spacingS),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  bool get _showPinchHint {
    if (_isImage) return true;
    if (_isPdf && !_pdfLoading && !_pdfFailed && _pdfController != null) {
      return true;
    }
    return false;
  }

  Widget _buildPreviewCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
      child: Container(
        width: double.infinity,
        decoration: DashboardScreenStyle.whiteCard(),
        child: child,
      ),
    );
  }

  Widget _buildBody() {
    final t = context.t.common.documentPreview;

    if (_isImage) {
      return _buildPreviewCard(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Center(
            child: Image.memory(
              widget.bytes,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    if (_isPdf) {
      if (_pdfLoading) {
        return _buildPreviewCard(
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (_pdfFailed || _pdfController == null) {
        return _UnavailableBody(
          fileName: widget.fileName,
          message: t.pdfUnavailable,
          isPdf: true,
        );
      }
      return _buildPreviewCard(
        child: PdfViewPinch(
          controller: _pdfController!,
          scrollDirection: Axis.vertical,
        ),
      );
    }

    return _UnavailableBody(
      fileName: widget.fileName,
      message: t.pdfUnavailable,
      isPdf: false,
    );
  }
}

class _UnavailableBody extends StatelessWidget {
  const _UnavailableBody({
    required this.fileName,
    required this.message,
    required this.isPdf,
  });

  final String fileName;
  final String message;
  final bool isPdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DashboardScreenStyle.whiteCard(),
      padding: const EdgeInsets.all(AppSizes.spacingL),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPdf
                ? Icons.picture_as_pdf_outlined
                : Icons.insert_drive_file_outlined,
            size: 72,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            fileName,
            style: AppTypography.body1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            message,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
