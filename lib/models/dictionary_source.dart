/// Which of the three dictionary tables an entry came from.
///
/// The old app queried `dz_dz`, `dz_en`, and `en_dz` as loose strings
/// scattered through `database.dart`. Centralizing them here means the
/// table name, display label, and search column are defined exactly once.
enum DictionarySource { dzDz, dzEn, enDz }

extension DictionarySourceInfo on DictionarySource {
  /// The SQLite table this source reads from.
  String get table {
    switch (this) {
      case DictionarySource.dzDz:
        return 'dz_dz';
      case DictionarySource.dzEn:
        return 'dz_en';
      case DictionarySource.enDz:
        return 'en_dz';
    }
  }

  /// The column holding the headword for this table.
  /// (`en_dz` calls it `keyword`; the other two call it `entry`.)
  String get headwordColumn {
    switch (this) {
      case DictionarySource.enDz:
        return 'keyword';
      case DictionarySource.dzDz:
      case DictionarySource.dzEn:
        return 'entry';
    }
  }

  /// Whether the *headword* is written in Dzongkha (Tibetan script).
  /// `en_dz`'s `keyword` column is English; the other two are Dzongkha.
  bool get headwordIsDzongkha => this != DictionarySource.enDz;

  /// Whether the *definition* is written in Dzongkha. Note this is
  /// independent of [headwordIsDzongkha]: `dz_en` has a Dzongkha headword
  /// but an *English* definition, while `en_dz` has an English headword
  /// but a *Dzongkha* definition.
  bool get definitionIsDzongkha => this != DictionarySource.dzEn;

  /// Short label shown on result cards, e.g. "Dzongkha" or "English".
  String get label {
    switch (this) {
      case DictionarySource.dzDz:
      case DictionarySource.dzEn:
        return 'Dzongkha';
      case DictionarySource.enDz:
        return 'English';
    }
  }

  static DictionarySource fromTable(String table) {
    switch (table) {
      case 'dz_dz':
        return DictionarySource.dzDz;
      case 'dz_en':
        return DictionarySource.dzEn;
      case 'en_dz':
        return DictionarySource.enDz;
      default:
        throw ArgumentError('Unknown dictionary table: $table');
    }
  }
}
