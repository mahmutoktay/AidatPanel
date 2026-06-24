enum ReportType { monthly, annual }

class ReportDownloadParams {
  const ReportDownloadParams({
    this.buildingId,
    this.siteId,
    required this.displayName,
    required this.type,
    required this.year,
    this.month,
  }) : assert(
          (buildingId != null) != (siteId != null),
          'buildingId veya siteId biri zorunlu',
        );

  final String? buildingId;
  final String? siteId;
  final String displayName;
  final ReportType type;
  final int year;
  final int? month;

  bool get isSiteReport => siteId != null;
}

class ReportFileResult {
  const ReportFileResult({
    required this.bytes,
    required this.fileName,
  });

  final List<int> bytes;
  final String fileName;
}
