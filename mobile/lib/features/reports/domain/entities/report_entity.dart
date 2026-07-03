enum ReportType { monthly, annual }

class ReportDownloadParams {
  const ReportDownloadParams({
<<<<<<< HEAD
    this.buildingId,
    this.siteId,
    required this.displayName,
=======
    this.buildingId = '',
    this.buildingName = '',
    this.siteId,
    this.siteName,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    required this.type,
    required this.year,
    this.month,
  }) : assert(
          (buildingId != null) != (siteId != null),
          'buildingId veya siteId biri zorunlu',
        );

<<<<<<< HEAD
  final String? buildingId;
  final String? siteId;
  final String displayName;
=======
  final String buildingId;
  final String buildingName;
  final String? siteId;
  final String? siteName;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  final ReportType type;
  final int year;
  final int? month;

<<<<<<< HEAD
  bool get isSiteReport => siteId != null;
=======
  bool get isSiteReport => siteId != null && siteId!.isNotEmpty;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
}

class ReportFileResult {
  const ReportFileResult({
    required this.bytes,
    required this.fileName,
  });

  final List<int> bytes;
  final String fileName;
}
