import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dictionary_entry.dart';
import '../models/dictionary_source.dart';
import '../providers/favorites_providers.dart';
import '../providers/settings_providers.dart';
import '../theme/app_theme.dart';

class WordDetailScreen extends ConsumerWidget {
  const WordDetailScreen({super.key, required this.entry});

  final DictionaryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontScale = ref.watch(settingsControllerProvider).fontScale;
    final favoriteAsync = ref.watch(isFavoriteProvider(entry));

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.source.label),
        actions: [
          IconButton(
            tooltip: 'Copy definition',
            icon: const Icon(Icons.copy_outlined),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: '${entry.headword}\n${entry.definition}'));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              }
            },
          ),
          favoriteAsync.when(
            data: (isFavorite) => IconButton(
              tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () => ref.read(favoritesActionsProvider).toggle(entry),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.headword,
              style: entry.source.headwordIsDzongkha
                  ? dzongkhaTextStyle(
                      baseSize: 32,
                      textScale: fontScale,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    )
                  : theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (entry.pos != null && entry.pos!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                entry.pos!,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
            const Divider(height: 32),
            Text(
              entry.definition,
              style: entry.source.definitionIsDzongkha
                  ? dzongkhaTextStyle(
                      baseSize: 20,
                      textScale: fontScale,
                      color: theme.colorScheme.onSurface,
                    )
                  : theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
