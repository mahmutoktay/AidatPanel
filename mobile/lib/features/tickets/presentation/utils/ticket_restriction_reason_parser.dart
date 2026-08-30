class ParsedTicketRestrictionReason {
  const ParsedTicketRestrictionReason({
    this.ticketTitle,
    this.ticketBody,
    this.managerNote,
    required this.fallback,
  });

  final String? ticketTitle;
  final String? ticketBody;
  final String? managerNote;
  final String fallback;

  bool get hasStructuredContent =>
      ticketTitle != null ||
      ticketBody != null ||
      managerNote != null;
}

ParsedTicketRestrictionReason parseTicketRestrictionReason(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return ParsedTicketRestrictionReason(fallback: trimmed);
  }

  if (!trimmed.startsWith('Talep: ')) {
    return ParsedTicketRestrictionReason(fallback: trimmed);
  }

  final lines = trimmed.split('\n');
  final firstLine = lines.first.substring('Talep: '.length).trim();
  String? title;
  String? body;

  final quoted = RegExp(r'^"([^"]*)"(.*)$').firstMatch(firstLine);
  if (quoted != null) {
    title = quoted.group(1)?.trim();
    final trailing = quoted.group(2)?.trim();
    if (trailing != null && trailing.isNotEmpty) {
      body = trailing;
    }
  } else {
    title = firstLine;
  }

  final bodyLines = <String>[];
  String? note;
  for (var i = 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.startsWith('Not: ')) {
      note = line.substring('Not: '.length).trim();
      break;
    }
    if (line.trim().isNotEmpty) bodyLines.add(line.trim());
  }

  if (body == null && bodyLines.isNotEmpty) {
    body = bodyLines.join('\n');
  }

  if (body != null && title != null && body == title) {
    body = null;
  }

  return ParsedTicketRestrictionReason(
    ticketTitle: title?.isEmpty == true ? null : title,
    ticketBody: body?.isEmpty == true ? null : body,
    managerNote: note?.isEmpty == true ? null : note,
    fallback: trimmed,
  );
}
