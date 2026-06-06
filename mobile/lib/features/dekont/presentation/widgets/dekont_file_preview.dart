import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';

/// Dekont dosyası önizlemesi — görsel tam ekran, PDF sayfa görünümü.
class DekontFilePreview extends StatefulWidget {
  final Uint8List bytes;
  final String mimeType;
  final String fileName;

  const DekontFilePreview({
    super.key,
    required this.bytes,
    required this.mimeType,
    required this.fileName,
  });

  bool get _isImage => mimeType.startsWith('image/');

  bool get _isPdf =>
      mimeType == 'application/pdf' ||
      fileName.toLowerCase().endsWith('.pdf');

  @override
  State<DekontFilePreview> createState() => _DekontFilePreviewState();
}

class _DekontFilePreviewState extends State<DekontFilePreview> {
  PdfControllerPinch? _pdfController;
  bool _pdfLoading = false;
  bool _pdfFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget._isPdf) {
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
      debugPrint('[dekont-pdf] platform: ${e.code} ${e.message}');
      if (mounted) {
        setState(() {
          _pdfLoading = false;
          _pdfFailed = true;
        });
      }
    } catch (e) {
      debugPrint('[dekont-pdf] open: $e');
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

  @override
  Widget build(BuildContext context) {
    if (widget._isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          widget.bytes,
          fit: BoxFit.contain,
        ),
      );
    }

    if (widget._isPdf) {
      final t = context.t.features.dekont;
      if (_pdfLoading) {
        return const SizedBox(
          height: 280,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (_pdfFailed || _pdfController == null) {
        return _PdfFallback(
          fileName: widget.fileName,
          message: t.pdfPreviewUnavailable,
        );
      }

      final maxHeight = math.min(
        480.0,
        MediaQuery.sizeOf(context).height * 0.55,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.pdfPreviewHint,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.spacingS),
          SizedBox(
            height: maxHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ColoredBox(
                color: Colors.white,
                child: PdfViewPinch(
                  controller: _pdfController!,
                  scrollDirection: Axis.vertical,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _FilePlaceholder(fileName: widget.fileName);
  }
}

class _PdfFallback extends StatelessWidget {
  final String fileName;
  final String message;

  const _PdfFallback({
    required this.fileName,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.picture_as_pdf,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Text(
                  fileName,
                  style: AppTypography.body1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            message,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FilePlaceholder extends StatelessWidget {
  final String fileName;

  const _FilePlaceholder({required this.fileName});

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;
    return _PdfFallback(
      fileName: fileName,
      message: t.pdfPreviewUnavailable,
    );
  }
}
