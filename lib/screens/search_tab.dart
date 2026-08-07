import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/history_providers.dart';
import '../providers/search_providers.dart';
import '../providers/settings_providers.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_row.dart';
import '../widgets/section_header.dart';

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

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final fontScale = ref.watch(settingsControllerProvider).fontScale;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ContentBounds(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                'རྫོང་ཁའི་ཚིག་མཛོད།',
                style: dzongkhaTextStyle(
                  baseSize: 26,
                  textScale: Responsive.fontBumpFor(context),
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  height: 1.3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search Dzongkha or English...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear), onPressed: _clear),
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
      ),
    );
  }

  Widget _buildEmptyQueryContent(double fontScale) {
    final wordOfDay = ref.watch(wordOfTheDayProvider);
    final history = ref.watch(historyProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SectionHeader(
          title: 'Word of the Day',
          trailing: TextButton.icon(
            onPressed: () => ref.read(wordOfTheDayActionsProvider).next(),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Next'),
          ),
        ),
        wordOfDay.when(
          // Without this, tapping "Next" collapses the section down to the
          // thin loading bar for a frame before the new word arrives,
          // reflowing everything below it -- a visible flicker for what's
          // an effectively instant local query. Keep showing the current
          // word until the next one is actually ready.
          skipLoadingOnReload: true,
          data: (entry) => entry == null
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('No word available.'),
                )
              : DecoratedBox(
                  decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest),
                  child: EntryRow(entry: entry, fontScale: fontScale),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: LinearProgressIndicator(),
          ),
          error: (_, __) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Your recent searches will show up here.'),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
    final theme = Theme.of(context);

    return results.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off,
            title: 'No matches found',
            subtitle:
                'Try a different spelling, or search in the other language.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          itemCount: entries.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: theme.colorScheme.outlineVariant,
          ),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return EntryRow(
              entry: entry,
              fontScale: fontScale,
              resultNumber: index + 1,
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
