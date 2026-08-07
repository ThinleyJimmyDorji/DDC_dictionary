import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dictionary_entry.dart';
import 'history_providers.dart';
import 'repository_providers.dart';

/// The *debounced* query that actually triggers a database search. The
/// search field keeps its own immediate text locally and only pushes here
/// after a short pause in typing (see `SearchTab`), so we're not hitting
/// SQLite on every keystroke.
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    FutureProvider.autoDispose<List<DictionaryEntry>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return const [];

  final repo = ref.watch(dictionaryRepositoryProvider);
  final results = await repo.search(query);

  if (results.isNotEmpty) {
    await repo.addHistory(query);
    ref.invalidate(historyProvider);
  }

  return results;
});

/// How many words forward of today's word the user has stepped, via the
/// "next word" action. Resets on app restart, so the day's actual word is
/// what greets you again next time -- this is a browsing aid, not a
/// setting worth persisting.
final wordOfTheDayOffsetProvider = StateProvider<int>((ref) => 0);

final wordOfTheDayProvider = FutureProvider<DictionaryEntry?>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  final offset = ref.watch(wordOfTheDayOffsetProvider);
  return repo.wordOfTheDay(offset: offset);
});

class WordOfTheDayActions {
  WordOfTheDayActions(this._ref);
  final Ref _ref;

  void next() {
    _ref
        .read(wordOfTheDayOffsetProvider.notifier)
        .update((offset) => offset + 1);
  }
}

final wordOfTheDayActionsProvider = Provider<WordOfTheDayActions>((ref) {
  return WordOfTheDayActions(ref);
});
