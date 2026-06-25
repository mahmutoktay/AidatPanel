import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/report_entity.dart';
import '../providers/report_provider.dart';
import '../screens/report_preview_screen.dart';

class SiteReportScreen extends ConsumerStatefulWidget {
  final String siteId;
  final String siteName;
  final ReportType type;

  const SiteReportScreen({
    super.key,
    required this.siteId,
    required this.siteName,
    required this.type,
  });

  @override
  ConsumerState<SiteReportScreen> createState() => _SiteReportScreenState();
}

class _SiteReportScreenState extends ConsumerState<SiteReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _download());
  }

  Future<void> _download() async {
    final now = DateTime.now();
    final params = ReportDownloadParams(
      siteId: widget.siteId,
      siteName: widget.siteName,
      type: widget.type,
      year: now.year,
      month: widget.type == ReportType.monthly ? now.month : null,
    );
    try {
      final result =
          await ref.read(reportServiceProvider).fetchReport(params);
      if (!mounted) return;
      await ReportPreviewScreen.open(
        context,
        result: result,
        subtitle: widget.siteName,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(context.t.features.reports.downloading),
          ],
        ),
      ),
    );
  }
}
