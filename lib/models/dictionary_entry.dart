import 'dictionary_source.dart';

/// A single dictionary sense/entry, unified across the three source tables.
///
/// `id` + `source` together are the stable identity used for favorites
/// (mirrors the `favorites` table's `UNIQUE(source, entry_id)` constraint).
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

  /// Row shape stored in the `favorites` table, keyed by (source, entry_id).
  factory DictionaryEntry.fromFavoriteRow(Map<String, Object?> row) {
    return DictionaryEntry(
      id: row['entry_id'] as int,
      source: DictionarySourceInfo.fromTable(row['source'] as String),
      headword: row['headword'] as String,
      pos: row['pos'] as String?,
      definition: row['definition'] as String,
    );
  }

  /// Stable key for favorite lookups / list diffing, e.g. "en_dz:1024".
  String get favoriteKey => '${source.table}:$id';

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
