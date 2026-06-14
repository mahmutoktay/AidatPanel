import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/strings.g.dart';

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
  static const _viewerBackground = Color(0xFF121212);

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

  @override
  Widget build(BuildContext context) {
    final t = context.t.common.documentPreview;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: _viewerBackground,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      child: Scaffold(
        backgroundColor: _viewerBackground,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: context.t.common.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.title,
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.fileName,
                style: AppTypography.caption.copyWith(
                  color: Colors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            if (widget.onDownload != null)
              IconButton(
                icon: const Icon(Icons.download_rounded),
                tooltip: context.t.common.save,
                onPressed: widget.onDownload,
              ),
            IconButton(
              icon: _sharing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.share_outlined),
              tooltip: t.share,
              onPressed: _sharing ? null : _handleShare,
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBody(),
            if (_showPinchHint)
              Positioned(
                left: AppSizes.spacingL,
                right: AppSizes.spacingL,
                bottom: AppSizes.spacingM + bottom,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingM,
                        vertical: AppSizes.spacingS,
                      ),
                      child: Text(
                        t.pinchHint,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
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

  Widget _buildBody() {
    final t = context.t.common.documentPreview;

    if (_isImage) {
      return InteractiveViewer(
        minScale: 0.8,
        maxScale: 5,
        child: Center(
          child: Image.memory(
            widget.bytes,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      );
    }

    if (_isPdf) {
      if (_pdfLoading) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
      if (_pdfFailed || _pdfController == null) {
        return _UnavailableBody(
          fileName: widget.fileName,
          message: t.pdfUnavailable,
          isPdf: true,
          onShare: _sharing ? null : _handleShare,
          shareLabel: t.share,
        );
      }
      return ColoredBox(
        color: Colors.white,
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
      onShare: _sharing ? null : _handleShare,
      shareLabel: t.share,
    );
  }
}

class _UnavailableBody extends StatelessWidget {
  const _UnavailableBody({
    required this.fileName,
    required this.message,
    required this.isPdf,
    required this.onShare,
    required this.shareLabel,
  });

  final String fileName;
  final String message;
  final bool isPdf;
  final VoidCallback? onShare;
  final String shareLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSizes.screenBodyScrollPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf_outlined : Icons.insert_drive_file_outlined,
              size: 72,
              color: Colors.white54,
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              fileName,
              style: AppTypography.body1.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              message,
              style: AppTypography.body2.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingL),
            if (onShare != null)
              FilledButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined),
                label: Text(shareLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(AppSizes.minTouchTargetComfort),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
