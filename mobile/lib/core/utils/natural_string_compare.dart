/// Alfabetik yerine doğal (sayısal) sıralama — örn. 1, 2, 10 (10, 1'den sonra değil).
int compareNaturalStrings(String a, String b, {String locale = 'tr'}) {
  final left = a.trim().toLowerCase();
  final right = b.trim().toLowerCase();
  if (left == right) return 0;

  final leftParts = _splitNaturalParts(left);
  final rightParts = _splitNaturalParts(right);
  final maxLen = leftParts.length > rightParts.length
      ? leftParts.length
      : rightParts.length;

  for (var i = 0; i < maxLen; i++) {
    final lp = i < leftParts.length ? leftParts[i] : '';
    final rp = i < rightParts.length ? rightParts[i] : '';
    if (lp == rp) continue;

    final leftIsNum = _isDigits(lp);
    final rightIsNum = _isDigits(rp);
    if (leftIsNum && rightIsNum) {
      final ln = int.tryParse(lp) ?? 0;
      final rn = int.tryParse(rp) ?? 0;
      final diff = ln.compareTo(rn);
      if (diff != 0) return diff;
      final lenDiff = lp.length.compareTo(rp.length);
      if (lenDiff != 0) return lenDiff;
      continue;
    }

    final textCompare = lp.compareTo(rp);
    if (textCompare != 0) return textCompare;
  }

  return left.length.compareTo(right.length);
}

List<String> _splitNaturalParts(String value) {
  final parts = <String>[];
  final buffer = StringBuffer();
  var inDigits = false;

  for (var i = 0; i < value.length; i++) {
    final ch = value[i];
    final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
    if (buffer.isEmpty) {
      inDigits = isDigit;
      buffer.write(ch);
      continue;
    }
    if (isDigit == inDigits) {
      buffer.write(ch);
    } else {
      parts.add(buffer.toString());
      buffer
        ..clear()
        ..write(ch);
      inDigits = isDigit;
    }
  }

  if (buffer.isNotEmpty) parts.add(buffer.toString());
  return parts;
}

bool _isDigits(String value) =>
    value.isNotEmpty && RegExp(r'^\d+$').hasMatch(value);

List<T> sortByNatural<T>(
  Iterable<T> items,
  String Function(T item) selector,
) {
  final list = items.toList();
  list.sort((a, b) => compareNaturalStrings(selector(a), selector(b)));
  return list;
}
