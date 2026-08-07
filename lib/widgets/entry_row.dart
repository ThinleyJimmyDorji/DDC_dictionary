import 'package:flutter/material.dart';

import '../models/dictionary_entry.dart';
import '../models/dictionary_source.dart';
import '../theme/app_theme.dart';
import '../utils/definition_senses.dart';
import '../utils/dzongkha_numerals.dart';
import '../utils/responsive.dart';
import 'pos_badge.dart';

/// Flat, edge-to-edge result row -- no Card, no elevation, no separate
/// detail page to tap into. The full definition (with multi-sense
/// formatting) is right here and selectable in place, so copying a word
/// or a single sense is a plain text-selection, not a popup + extra tap.
///
/// The part-of-speech badge leads the headword (far left) rather than
/// trailing it, so the grammatical category is the first thing scanned,
/// matching how print dictionaries lead with it.
class EntryRow extends StatelessWidget {
  const EntryRow({
    super.key,
    required this.entry,
    required this.fontScale,
    this.resultNumber,
  });

  final DictionaryEntry entry;
  final double fontScale;

  /// 1-based position in the results list, rendered as a Dzongkha numeral.
  /// Null for contexts without an ordinal position (Word of the Day).
  final int? resultNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final senses = splitDefinitionSenses(entry.definition);
    final isTablet = Responsive.isTablet(context);
    // The user's own Settings text-size slider, layered under a small
    // automatic bump on larger screens (tablets are typically read from
    // further away, so the same point size reads relatively smaller).
    final scale = fontScale * Responsive.fontBumpFor(context);

    return Padding(
      padding: isTablet
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 18)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (resultNumber != null) ...[
                SizedBox(
                  width: isTablet ? 34 : 30,
                  child: Text(
                    '${toDzongkhaNumeral(resultNumber!)}.',
                    style: dzongkhaTextStyle(
                      baseSize: 15,
                      textScale: scale,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
              if (entry.pos != null && entry.pos!.trim().isNotEmpty) ...[
                PosBadge(pos: entry.pos),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: SelectableText(
                  entry.headword,
                  style: entry.source.headwordIsDzongkha
                      ? dzongkhaTextStyle(
                          baseSize: 19,
                          textScale: scale,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: theme.colorScheme.onSurface,
                        )
                      : theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize:
                              (theme.textTheme.titleMedium?.fontSize ?? 16) *
                                  scale,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < senses.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _Sense(
              index: senses.length > 1 ? i + 1 : null,
              text: senses[i],
              isDzongkha: entry.source.definitionIsDzongkha,
              fontScale: scale,
            ),
          ],
          const SizedBox(height: 6),
          Text(
            entry.source.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sense extends StatelessWidget {
  const _Sense(
      {required this.index,
      required this.text,
      required this.isDzongkha,
      required this.fontScale});

  final int? index;
  final String text;
  final bool isDzongkha;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = isDzongkha
        ? dzongkhaTextStyle(
            baseSize: 15,
            textScale: fontScale,
            height: 1.6,
            color: theme.colorScheme.onSurfaceVariant,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * fontScale,
          );

    if (index == null) {
      return SelectableText(text, style: style);
    }

    final numeral = isDzongkha ? toDzongkhaNumeral(index!) : '$index';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isDzongkha ? 28 : 22,
          child: Text(
            '$numeral.',
            style: (isDzongkha
                    ? dzongkhaTextStyle(
                        baseSize: 15,
                        textScale: fontScale,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                      )
                    : style)
                ?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary),
          ),
        ),
        Expanded(child: SelectableText(text, style: style)),
      ],
    );
  }
}
