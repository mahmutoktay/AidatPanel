enum ReportType { monthly, annual }

class ReportDownloadParams {
  const ReportDownloadParams({
    this.buildingId = '',
    this.buildingName = '',
    this.siteId,
    this.siteName,
    required this.type,
    required this.year,
    this.month,
  });

  final String buildingId;
  final String buildingName;
  final String? siteId;
  final String? siteName;
  final ReportType type;
  final int year;
  final int? month;

  bool get isSiteReport => siteId != null && siteId!.isNotEmpty;
}

class ReportFileResult {
  const ReportFileResult({
    required this.bytes,
    required this.fileName,
  });

  final List<int> bytes;
  final String fileName;
}
