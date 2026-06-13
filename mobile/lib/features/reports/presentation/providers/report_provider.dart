import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSourceImpl(dioClient: ref.watch(dioClientProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(remote: ref.watch(reportRemoteDataSourceProvider));
});

final reportServiceProvider = Provider((ref) => ReportService(ref));

class ReportService {
  ReportService(this._ref);

  final Ref _ref;

  Future<ReportFileResult> fetchReport(ReportDownloadParams params) {
    return _ref.read(reportRepositoryProvider).downloadReport(params);
  }

  Future<void> shareReport(ReportFileResult result) async {
    final bytes = Uint8List.fromList(result.bytes);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'application/pdf',
              name: result.fileName,
            ),
          ],
          subject: result.fileName,
        ),
      );
    } catch (_) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${result.fileName}');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: result.fileName,
        ),
      );
    }
  }
}

/// Geriye uyumluluk — eski provider adı.
@Deprecated('Use reportServiceProvider')
final reportDownloadServiceProvider = reportServiceProvider;
