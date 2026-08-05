import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repository_providers.dart';

/// Recent search terms, most recent first. Invalidated whenever a new
/// search succeeds or the user clears history.
final historyProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.getRecentHistory();
});

class HistoryActions {
  HistoryActions(this._ref);
  final Ref _ref;

  Future<void> clear() async {
    final repo = _ref.read(dictionaryRepositoryProvider);
    await repo.clearHistory();
    _ref.invalidate(historyProvider);
  }
}

final historyActionsProvider = Provider<HistoryActions>((ref) {
  return HistoryActions(ref);
});
