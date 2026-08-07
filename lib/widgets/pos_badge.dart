import 'package:flutter/material.dart';

import '../theme/pos_colors.dart';

/// Vibrant, color-coded part-of-speech pill. Placed leading (far left) of
/// an entry, not trailing, so the grammatical category reads before the
/// word itself -- the fast-scan cue a dictionary needs.
///
/// Shows the Dzongkha grammatical term alongside the English label (e.g.
/// "noun/མིང་ཚིག") when the dictionary has one. Text is drawn in the
/// category color at full strength; the fill is the same color at low
/// opacity, so the color reads as a tint rather than a solid block.
class PosBadge extends StatelessWidget {
  const PosBadge({super.key, required this.pos, this.dense = false});

  final String? pos;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final style = posStyleFor(pos);
    if (style == null) return const SizedBox.shrink();

    final fontSize = dense ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: style.color,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            height: 1.2,
          ),
          children: [
            TextSpan(text: style.label),
            if (style.dzongkhaTerm != null) ...[
              const TextSpan(text: '/'),
              TextSpan(
                text: style.dzongkhaTerm,
                style: const TextStyle(
                    fontFamily: 'jomolhari', fontWeight: FontWeight.normal),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
