import 'package:ddc_dictionary/models/dictionary_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DictionarySource', () {
    test('table names match the actual SQLite tables', () {
      expect(DictionarySource.dzDz.table, 'dz_dz');
      expect(DictionarySource.dzEn.table, 'dz_en');
      expect(DictionarySource.enDz.table, 'en_dz');
    });

    test('headwordColumn: en_dz uses keyword, the others use entry', () {
      expect(DictionarySource.dzDz.headwordColumn, 'entry');
      expect(DictionarySource.dzEn.headwordColumn, 'entry');
      expect(DictionarySource.enDz.headwordColumn, 'keyword');
    });

    test('headwordIsDzongkha is true for dz_dz/dz_en, false for en_dz', () {
      expect(DictionarySource.dzDz.headwordIsDzongkha, isTrue);
      expect(DictionarySource.dzEn.headwordIsDzongkha, isTrue);
      expect(DictionarySource.enDz.headwordIsDzongkha, isFalse);
    });

    // This is the one that's easy to get backwards: dz_en's *headword* is
    // Dzongkha but its *definition* is English, while en_dz is the mirror
    // image. Regression test for that exact mix-up (it happened once
    // already while writing entry_card.dart).
    test('definitionIsDzongkha is independent of headwordIsDzongkha', () {
      expect(DictionarySource.dzDz.definitionIsDzongkha, isTrue);
      expect(DictionarySource.dzEn.definitionIsDzongkha, isFalse);
      expect(DictionarySource.enDz.definitionIsDzongkha, isTrue);
    });

    test('fromTable round-trips with table for every source', () {
      for (final source in DictionarySource.values) {
        expect(DictionarySourceInfo.fromTable(source.table), source);
      }
    });

    test('fromTable throws for an unknown table name', () {
      expect(() => DictionarySourceInfo.fromTable('nope'), throwsArgumentError);
    });
  });
}
