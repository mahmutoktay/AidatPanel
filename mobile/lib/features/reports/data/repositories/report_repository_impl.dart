import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({required ReportRemoteDataSource remote}) : _remote = remote;

  final ReportRemoteDataSource _remote;

  @override
  Future<ReportFileResult> downloadReport(ReportDownloadParams params) {
    return _remote.downloadReport(params);
  }
}
