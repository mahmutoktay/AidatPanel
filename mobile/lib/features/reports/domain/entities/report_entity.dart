enum ReportType { monthly, annual }

class ReportDownloadParams {
  const ReportDownloadParams({
    required this.buildingId,
    required this.buildingName,
    required this.type,
    required this.year,
    this.month,
  });

  final String buildingId;
  final String buildingName;
  final ReportType type;
  final int year;
  final int? month;
}

class ReportFileResult {
  const ReportFileResult({
    required this.bytes,
    required this.fileName,
  });

  final List<int> bytes;
  final String fileName;
}
