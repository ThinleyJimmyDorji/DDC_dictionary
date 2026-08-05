import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dictionary_entry.dart';
import 'repository_providers.dart';

final favoritesProvider = FutureProvider.autoDispose<List<DictionaryEntry>>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.getFavorites();
});

/// Per-entry favorite status, so a search-result card can show a filled or
/// outline heart without loading the whole favorites list.
final isFavoriteProvider =
    FutureProvider.autoDispose.family<bool, DictionaryEntry>((ref, entry) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.isFavorite(entry);
});

class FavoritesActions {
  FavoritesActions(this._ref);
  final Ref _ref;

  Future<void> toggle(DictionaryEntry entry) async {
    final repo = _ref.read(dictionaryRepositoryProvider);
    final isFavorite = await repo.isFavorite(entry);
    if (isFavorite) {
      await repo.removeFavorite(entry);
    } else {
      await repo.addFavorite(entry);
    }
    _ref.invalidate(favoritesProvider);
    _ref.invalidate(isFavoriteProvider(entry));
  }
}

final favoritesActionsProvider = Provider<FavoritesActions>((ref) {
  return FavoritesActions(ref);
});
