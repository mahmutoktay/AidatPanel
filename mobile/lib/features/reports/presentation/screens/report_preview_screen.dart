import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
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

  Widget _buildShareBar(BuildContext context) {
    final t = context.t.features.reports;

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: ProfileSettingsUi.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: _sharing ? null : _onShare,
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
            label: Text(t.shareReport),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.reports;

    return DashboardSecondaryScaffold(
      title: t.previewTitle,
      bottomNavigationBar: _buildShareBar(context),
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
              widget.subtitle,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.spacingS),
            Expanded(child: _buildPreviewBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewBody() {
    final t = context.t.features.reports;

    if (_pdfLoading) {
      return Container(
        decoration: DashboardScreenStyle.whiteCard(),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_pdfFailed || _pdfController == null) {
      return Container(
        decoration: DashboardScreenStyle.whiteCard(),
        padding: const EdgeInsets.all(AppSizes.spacingL),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 64,
              color: AppColors.brand,
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
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.pdfPreviewHint,
          style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
            child: Container(
              decoration: DashboardScreenStyle.whiteCard(),
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
}
