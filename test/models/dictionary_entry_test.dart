import 'package:ddc_dictionary/models/dictionary_entry.dart';
import 'package:ddc_dictionary/models/dictionary_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DictionaryEntry.fromRow', () {
    test('reads entry/definition for dz_dz, with no pos column', () {
      final entry = DictionaryEntry.fromRow(DictionarySource.dzDz, {
        'id': 1,
        'entry': 'ཀ།',
        'definition': 'གསལ་བྱེད་སུམ་ཅུའི་དང་པོ།',
      });

      expect(entry.id, 1);
      expect(entry.source, DictionarySource.dzDz);
      expect(entry.headword, 'ཀ།');
      expect(entry.pos, isNull);
      expect(entry.definition, 'གསལ་བྱེད་སུམ་ཅུའི་དང་པོ།');
    });

    test('reads keyword (not entry) as the headword for en_dz', () {
      final entry = DictionaryEntry.fromRow(DictionarySource.enDz, {
        'id': 18288,
        'keyword': 'processor',
        'pos': 'noun',
        'definition': 'སྦྱོར་འཕྲུལ།',
      });

      expect(entry.headword, 'processor');
      expect(entry.pos, 'noun');
    });

    test('missing headword column falls back to empty string, not a crash', () {
      final entry = DictionaryEntry.fromRow(DictionarySource.dzEn, {
        'id': 1,
        'definition': 'something',
      });
      expect(entry.headword, '');
    });
  });

  group('DictionaryEntry.fromFavoriteRow', () {
    test('maps the favorites table row shape back to an entry', () {
      final entry = DictionaryEntry.fromFavoriteRow({
        'source': 'en_dz',
        'entry_id': 42,
        'headword': 'aardvark',
        'pos': 'noun',
        'definition': 'གྱོག་དོམ།',
        'created_at': 1700000000000,
      });

      expect(entry.id, 42);
      expect(entry.source, DictionarySource.enDz);
      expect(entry.headword, 'aardvark');
    });
  });

  group('identity', () {
    test('favoriteKey combines table name and id', () {
      final entry = DictionaryEntry.fromRow(DictionarySource.enDz, {
        'id': 7,
        'keyword': 'word',
        'pos': 'noun',
        'definition': 'x',
      });
      expect(entry.favoriteKey, 'en_dz:7');
    });

    test('equality/hashCode are based on (source, id), not content', () {
      final a = DictionaryEntry.fromRow(DictionarySource.enDz, {
        'id': 7,
        'keyword': 'word',
        'pos': 'noun',
        'definition': 'first definition',
      });
      final b = DictionaryEntry.fromRow(DictionarySource.enDz, {
        'id': 7,
        'keyword': 'word',
        'pos': 'noun',
        'definition': 'a different definition entirely',
      });
      final differentSource = DictionaryEntry.fromRow(DictionarySource.dzEn, {
        'id': 7,
        'entry': 'word',
        'pos': 'noun',
        'definition': 'x',
      });

      expect(a, equals(b), reason: 'same (source, id) should be equal regardless of content');
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(differentSource)), reason: 'same id but different source must differ');
    });

    test('copyWith replaces only the definition', () {
      final original = DictionaryEntry.fromRow(DictionarySource.dzDz, {
        'id': 1,
        'entry': 'ཀ།',
        'definition': 'old',
      });
      final updated = original.copyWith(definition: 'new');

      expect(updated.definition, 'new');
      expect(updated.id, original.id);
      expect(updated.source, original.source);
      expect(updated.headword, original.headword);
    });
  });
}
