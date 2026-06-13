import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<ReportFileResult> downloadReport(ReportDownloadParams params);
}
