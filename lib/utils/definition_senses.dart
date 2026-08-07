/// Best-effort split of definitions that pack multiple numbered senses into
/// one blob, e.g. "1 curl, winding 2 devious" or "༡ ... ༢ ...". Only
/// splits when the text actually starts with a sense marker and at least
/// one more marker follows -- otherwise a definition that merely mentions
/// a number would get mangled.
List<String> splitDefinitionSenses(String definition) {
  final trimmed = definition.trim();
  if (trimmed.isEmpty) return const [];

  final leadingMarker = RegExp(r'^(?:[0-9]{1,2}|[༠-༩]{1,2})\s');
  if (!leadingMarker.hasMatch(trimmed)) return [trimmed];

  final markerPattern = RegExp(r'(?:^|\s)(?:[0-9]{1,2}|[༠-༩]{1,2})\s');
  final matches = markerPattern.allMatches(trimmed).toList();
  if (matches.length < 2) return [trimmed];

  final senses = <String>[];
  for (var i = 0; i < matches.length; i++) {
    final start = matches[i].end;
    final end = i + 1 < matches.length ? matches[i + 1].start : trimmed.length;
    if (start >= end) continue;
    final sense = trimmed.substring(start, end).trim();
    if (sense.isNotEmpty) senses.add(sense);
  }
  return senses.isEmpty ? [trimmed] : senses;
}
