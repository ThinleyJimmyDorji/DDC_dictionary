import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dictionary_entry.dart';
import '../models/dictionary_source.dart';
import '../providers/favorites_providers.dart';
import '../theme/app_theme.dart';

/// Result-list / favorites-list row for a single dictionary entry.
///
/// Shows the headword in the correct script/font (Jomolhari for Dzongkha
/// entries, default font for English ones), the part of speech if known,
/// a definition snippet, a source tag ("Dzongkha"/"English"), and a
/// favorite toggle that updates instantly via Riverpod without needing to
/// reload the whole list.
class EntryCard extends ConsumerWidget {
  const EntryCard({
    super.key,
    required this.entry,
    required this.fontScale,
    required this.onTap,
    this.maxDefinitionLines = 2,
  });

  final DictionaryEntry entry;
  final double fontScale;
  final VoidCallback onTap;
  final int maxDefinitionLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteAsync = ref.watch(isFavoriteProvider(entry));

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.headword,
                            style: entry.source.headwordIsDzongkha
                                ? dzongkhaTextStyle(
                                    baseSize: 20,
                                    textScale: fontScale,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                    color: theme.colorScheme.onSurface,
                                  )
                                : theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          ),
                        ),
                        if (entry.pos != null && entry.pos!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              entry.pos!,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.definition,
                      maxLines: maxDefinitionLines,
                      overflow: TextOverflow.ellipsis,
                      style: entry.source.definitionIsDzongkha
                          ? dzongkhaTextStyle(
                              baseSize: 16,
                              textScale: fontScale,
                              height: 1.6,
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.source.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              favoriteAsync.when(
                data: (isFavorite) => IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? theme.colorScheme.primary : theme.colorScheme.outline,
                  ),
                  onPressed: () => ref.read(favoritesActionsProvider).toggle(entry),
                ),
                loading: () => const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox(width: 48, height: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
