/// Talep oluşturma formu — API uyumu için başlık türetme.
String deriveTicketTitle(String description) {
  final trimmed = description.trim();
  if (trimmed.isEmpty) return 'Talep';

  final firstLine = trimmed.split(RegExp(r'\r?\n')).first.trim();
  if (firstLine.isEmpty) return 'Talep';
  if (firstLine.length <= 120) return firstLine;
  return '${firstLine.substring(0, 117)}...';
}
