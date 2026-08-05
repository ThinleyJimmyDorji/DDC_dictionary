import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dictionary_entry.dart';
import '../providers/history_providers.dart';
import '../providers/search_providers.dart';
import '../providers/settings_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_card.dart';
import '../widgets/section_header.dart';
import 'word_detail_screen.dart';

/// The home tab: a live, debounced search over the dictionary, with a
/// Word of the Day and recent-search chips shown while the field is empty.
///
/// This replaces the old app's broken search flow, where typing a word
/// didn't actually search anything unless you tapped a suggestion from a
/// hardcoded, unrelated English word list.
class SearchTab extends ConsumerStatefulWidget {
  const SearchTab({super.key});

  @override
  ConsumerState<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<SearchTab> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Rebuild locally on every keystroke so the clear button appears
    // immediately, independent of the debounced provider update below.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  void _selectHistory(String term) {
    _controller
      ..text = term
      ..selection = TextSelection.collapsed(offset: term.length);
    _debounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = term;
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  void _openDetail(DictionaryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WordDetailScreen(entry: entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final fontScale = ref.watch(settingsControllerProvider).fontScale;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'རྫོང་ཁའི་ཚིག་མཛོད།',
          style: dzongkhaTextStyle(
            baseSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search Dzongkha or English...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
              ),
            ),
          ),
          Expanded(
            child: query.trim().isEmpty
                ? _buildEmptyQueryContent(fontScale)
                : _buildResults(fontScale),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueryContent(double fontScale) {
    final wordOfDay = ref.watch(wordOfTheDayProvider);
    final history = ref.watch(historyProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SectionHeader(title: 'Word of the Day'),
        wordOfDay.when(
          data: (entry) => entry == null
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No word available.'),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: EntryCard(
                    entry: entry,
                    fontScale: fontScale,
                    maxDefinitionLines: 4,
                    onTap: () => _openDetail(entry),
                  ),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
          error: (_, __) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Could not load word of the day.'),
          ),
        ),
        SectionHeader(
          title: 'Recent Searches',
          trailing: history.maybeWhen(
            data: (items) => items.isEmpty
                ? null
                : TextButton(
                    onPressed: () => ref.read(historyActionsProvider).clear(),
                    child: const Text('Clear'),
                  ),
            orElse: () => null,
          ),
        ),
        history.when(
          data: (items) => items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Your recent searches will show up here.'),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: items
                        .map(
                          (term) => ActionChip(
                            label: Text(term),
                            onPressed: () => _selectHistory(term),
                          ),
                        )
                        .toList(),
                  ),
                ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildResults(double fontScale) {
    final results = ref.watch(searchResultsProvider);
    return results.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off,
            title: 'No matches found',
            subtitle: 'Try a different spelling, or search in the other language.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: EntryCard(
                entry: entry,
                fontScale: fontScale,
                onTap: () => _openDetail(entry),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        subtitle: '$error',
      ),
    );
  }
}
