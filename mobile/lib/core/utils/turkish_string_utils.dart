/// Türkçe alfabetik sıralama ve arama normalizasyonu.
library;

/// Türkçe karakterleri arama için ASCII-benzeri forma çevirir.
/// Örn. "İstanbul" → "istanbul", "is" sorgusu eşleşir.
String normalizeTurkishForSearch(String input) {
  final buffer = StringBuffer();
  for (final code in input.runes) {
    buffer.writeCharCode(_normalizeRuneForSearch(code));
  }
  return buffer.toString();
}

int _normalizeRuneForSearch(int code) {
  switch (code) {
    case 0x0049: // I
    case 0x0130: // İ
    case 0x0069: // i
    case 0x0131: // ı
      return 0x0069; // i
    case 0x00C7: // Ç
    case 0x00E7: // ç
      return 0x0063; // c
    case 0x011E: // Ğ
    case 0x011F: // ğ
      return 0x0067; // g
    case 0x00D6: // Ö
    case 0x00F6: // ö
      return 0x006F; // o
    case 0x015E: // Ş
    case 0x015F: // ş
      return 0x0073; // s
    case 0x00DC: // Ü
    case 0x00FC: // ü
      return 0x0075; // u
    default:
      final lower = String.fromCharCode(code).toLowerCase();
      return lower.codeUnitAt(0);
  }
}

/// Türkçe alfabetik sıralama anahtarı (a…z, ç ğ ı ö ş ü doğru sırada).
String turkishSortKey(String input) {
  final buffer = StringBuffer();
  for (final code in input.runes) {
    buffer.write(_turkishCharSortToken(code));
  }
  return buffer.toString();
}

String _turkishCharSortToken(int code) {
  final ch = String.fromCharCode(code);
  final lower = _turkishLowerChar(ch);
  const weights = <String, String>{
    'a': '010',
    'â': '011',
    'b': '020',
    'c': '030',
    'ç': '040',
    'd': '050',
    'e': '060',
    'ê': '061',
    'f': '070',
    'g': '080',
    'ğ': '090',
    'h': '100',
    'ı': '110',
    'i': '120',
    'j': '130',
    'k': '140',
    'l': '150',
    'm': '160',
    'n': '170',
    'o': '180',
    'ö': '190',
    'p': '200',
    'r': '210',
    's': '220',
    'ş': '230',
    't': '240',
    'u': '250',
    'ü': '260',
    'v': '270',
    'y': '280',
    'z': '290',
    ' ': '300',
    '-': '301',
  };
  return weights[lower] ?? '900${lower.codeUnitAt(0).toString().padLeft(4, '0')}';
}

String _turkishLowerChar(String ch) {
  if (ch == 'İ') return 'i';
  if (ch == 'I') return 'ı';
  return ch.toLowerCase();
}

int compareTurkish(String a, String b) {
  return turkishSortKey(a).compareTo(turkishSortKey(b));
}

/// Arama önceliği: düşük skor = üstte.
int turkishSearchRank(String query, String candidate) {
  final q = normalizeTurkishForSearch(query.trim());
  if (q.isEmpty) return 0;

  final n = normalizeTurkishForSearch(candidate);
  if (n.startsWith(q)) return 0;

  final words = n.split(RegExp(r'[\s\-]+'));
  for (var i = 0; i < words.length; i++) {
    if (words[i].startsWith(q)) return 10 + i;
  }

  final index = n.indexOf(q);
  if (index >= 0) return 100 + index;

  return 10000;
}

List<String> sortTurkishList(Iterable<String> items) {
  final list = items.toList();
  list.sort(compareTurkish);
  return list;
}

List<String> filterTurkishSearch(
  Iterable<String> items,
  String query, {
  int Function(String item)? weight,
}) {
  final q = normalizeTurkishForSearch(query.trim());
  if (q.isEmpty) return sortTurkishList(items);

  final matches = items
      .where((item) => normalizeTurkishForSearch(item).contains(q))
      .toList();

  matches.sort((a, b) {
    final rankDiff = turkishSearchRank(query, a).compareTo(
      turkishSearchRank(query, b),
    );
    if (rankDiff != 0) return rankDiff;
    if (weight != null) {
      final popDiff = weight(b).compareTo(weight(a));
      if (popDiff != 0) return popDiff;
    }
    return compareTurkish(a, b);
  });

  return matches;
}
