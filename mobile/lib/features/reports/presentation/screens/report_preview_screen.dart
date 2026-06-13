import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/report_entity.dart';
import '../providers/report_provider.dart';

/// Tam ekran PDF rapor önizlemesi + altta paylaş butonu.
class ReportPreviewScreen extends ConsumerStatefulWidget {
  const ReportPreviewScreen({
    super.key,
    required this.result,
    required this.subtitle,
  });

  final ReportFileResult result;
  final String subtitle;

  static Future<void> open(
    BuildContext context, {
    required ReportFileResult result,
    required String subtitle,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReportPreviewScreen(
          result: result,
          subtitle: subtitle,
        ),
      ),
    );
  }

  @override
  ConsumerState<ReportPreviewScreen> createState() =>
      _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends ConsumerState<ReportPreviewScreen> {
  PdfControllerPinch? _pdfController;
  bool _pdfLoading = true;
  bool _pdfFailed = false;
  bool _sharing = false;

  Uint8List get _bytes => Uint8List.fromList(widget.result.bytes);

  @override
  void initState() {
    super.initState();
    _openPdf();
  }

  Future<void> _openPdf() async {
    try {
      final controller = PdfControllerPinch(
        document: PdfDocument.openData(_bytes),
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
      debugPrint('[reports-pdf] platform: ${e.code} ${e.message}');
      if (mounted) {
        setState(() {
          _pdfLoading = false;
          _pdfFailed = true;
        });
      }
    } catch (e) {
      debugPrint('[reports-pdf] open: $e');
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

  Future<void> _onShare() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await ref.read(reportServiceProvider).shareReport(widget.result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userFacingError(e, context: ApiMessageContext.general),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.reports;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.previewTitle,
              style: AppTypography.h3.copyWith(fontSize: 18),
            ),
            Text(
              widget.subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildPreviewBody()),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.spacingM,
              AppSizes.spacingS,
              AppSizes.spacingM,
              AppSizes.spacingM + bottom,
            ),
            child: SizedBox(
              height: AppSizes.minTouchTargetComfort,
              child: FilledButton.icon(
                onPressed: _sharing ? null : _onShare,
                icon: _sharing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share_outlined),
                label: Text(t.shareReport),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBody() {
    final t = context.t.features.reports;
    if (_pdfLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pdfFailed || _pdfController == null) {
      return Padding(
        padding: AppSizes.screenBodyScrollPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              widget.result.fileName,
              style: AppTypography.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              t.pdfPreviewUnavailable,
              style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacingM,
            AppSizes.spacingS,
            AppSizes.spacingM,
            0,
          ),
          child: Text(
            t.pdfPreviewHint,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Expanded(
          child: ColoredBox(
            color: Colors.white,
            child: PdfViewPinch(
              controller: _pdfController!,
              scrollDirection: Axis.vertical,
            ),
          ),
        ),
      ],
    );
  }
}
