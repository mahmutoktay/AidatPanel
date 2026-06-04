import 'dekont_entity.dart';

/// Upload sonucu — recovery veya normal yanıt ayrımı için.
class DekontUploadResult {
  const DekontUploadResult({
    required this.dekont,
    this.recovered = false,
  });

  final DekontEntity dekont;
  final bool recovered;
}
