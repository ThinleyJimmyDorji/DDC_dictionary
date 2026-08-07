import 'dictionary_source.dart';

/// A single dictionary sense/entry, unified across the three source tables.
///
/// `id` + `source` together are the stable identity for equality/diffing.
class DictionaryEntry {
  final int id;
  final DictionarySource source;
  final String headword;
  final String? pos;
  final String definition;

  const DictionaryEntry({
    required this.id,
    required this.source,
    required this.headword,
    required this.pos,
    required this.definition,
  });

  factory DictionaryEntry.fromRow(
    DictionarySource source,
    Map<String, Object?> row,
  ) {
    return DictionaryEntry(
      id: row['id'] as int,
      source: source,
      headword: (row[source.headwordColumn] as String?) ?? '',
      pos: row['pos'] as String?,
      definition: (row['definition'] as String?) ?? '',
    );
  }

  DictionaryEntry copyWith({String? definition}) => DictionaryEntry(
        id: id,
        source: source,
        headword: headword,
        pos: pos,
        definition: definition ?? this.definition,
      );

  @override
  bool operator ==(Object other) =>
      other is DictionaryEntry && other.id == id && other.source == source;

  @override
  int get hashCode => Object.hash(id, source);
}
