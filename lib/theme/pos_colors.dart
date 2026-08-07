import 'package:flutter/material.dart';

/// Broad grammatical categories the messy `pos` column gets normalized
/// into. The source data mixes clean tags ("noun", "verb") with debris
/// from the old print dictionary ("ia:", "n", "v.t."), so this is a
/// best-effort classification, not a parser.
enum PosCategory {
  noun,
  verb,
  adjective,
  adverb,
  pronoun,
  preposition,
  conjunction,
  interjection,
  other
}

class PosStyle {
  const PosStyle(
      {required this.category,
      required this.label,
      required this.color,
      this.dzongkhaTerm});

  final PosCategory category;

  /// Short, consistent badge label (e.g. "noun", "verb"), independent of
  /// however the source data happened to abbreviate it.
  final String label;

  /// Base color for the badge -- text is drawn in this color at full
  /// opacity, the fill is this color at low opacity. Chosen saturated/dark
  /// enough to stay legible as text on both light and dark backgrounds.
  final Color color;

  /// The Dzongkha word for this grammatical category, e.g. "མིང་ཚིག" for
  /// noun -- looked up from the en_dz table (keyword = "noun" etc.), not
  /// guessed. Null for categories not present in the dictionary itself
  /// (pronoun, interjection) or that don't map to a single clean term.
  final String? dzongkhaTerm;
}

/// Reads a raw `pos` string (may be null, empty, or dictionary-debris like
/// "ia:") and returns a badge style, or null if there's nothing worth
/// showing.
PosStyle? posStyleFor(String? rawPos) {
  final raw = (rawPos ?? '').trim().toLowerCase();
  if (raw.isEmpty) return null;

  // Strip trailing punctuation/dots so "adj.", "n.", "v.t." etc. match.
  final cleaned = raw.replaceAll(RegExp(r'[.:]'), ' ').trim();
  final firstWord = cleaned.split(RegExp(r'\s+')).first;

  PosCategory? category;
  String? label;

  bool matches(List<String> tags) =>
      tags.contains(firstWord) || tags.contains(cleaned);

  if (matches(['noun', 'n'])) {
    category = PosCategory.noun;
    label = 'noun';
  } else if (matches(['verb', 'v', 'vt', 'vi', 'v t', 'v i'])) {
    category = PosCategory.verb;
    label = 'verb';
  } else if (matches(['adj', 'adjective'])) {
    category = PosCategory.adjective;
    label = 'adj.';
  } else if (matches(['adv', 'adverb'])) {
    category = PosCategory.adverb;
    label = 'adv.';
  } else if (matches(['pron', 'pronoun'])) {
    category = PosCategory.pronoun;
    label = 'pron.';
  } else if (matches(['prep', 'preposition'])) {
    category = PosCategory.preposition;
    label = 'prep.';
  } else if (matches(['conj', 'conjunction'])) {
    category = PosCategory.conjunction;
    label = 'conj.';
  } else if (matches(['interj', 'interjection', 'excl', 'exclamation'])) {
    category = PosCategory.interjection;
    label = 'interj.';
  }

  if (category == null || label == null) {
    // Unrecognized debris (e.g. "ia:") -- still worth a badge, just show
    // the raw text as-is rather than guessing.
    final trimmed = (rawPos ?? '').trim();
    if (trimmed.isEmpty) return null;
    return PosStyle(
        category: PosCategory.other,
        label: trimmed,
        color: _colors[PosCategory.other]!);
  }

  return PosStyle(
    category: category,
    label: label,
    color: _colors[category]!,
    dzongkhaTerm: _dzongkhaTerms[category],
  );
}

const _colors = <PosCategory, Color>{
  PosCategory.noun: Color(0xFF2F7D63),
  PosCategory.verb: Color(0xFFB23A48),
  PosCategory.adjective: Color(0xFF6355A8),
  PosCategory.adverb: Color(0xFFA66A15),
  PosCategory.pronoun: Color(0xFF2F6FA6),
  PosCategory.preposition: Color(0xFF7A5231),
  PosCategory.conjunction: Color(0xFF5C4A72),
  PosCategory.interjection: Color(0xFFA6472F),
  PosCategory.other: Color(0xFF5B5347),
};

/// Sourced from the en_dz table itself (keyword = "noun" / "verb" / etc.),
/// taking the concise standard term from each entry's definition -- not a
/// guess. Categories with no entry in the dictionary (pronoun) or whose
/// entry doesn't reduce to one clean word (interjection) are omitted; the
/// badge just shows the English label for those.
const _dzongkhaTerms = <PosCategory, String>{
  PosCategory.noun: 'མིང་ཚིག',
  PosCategory.verb: 'བྱ་ཚིག',
  PosCategory.adjective: 'ཁྱད་ཚིག',
  PosCategory.adverb: 'དབྱེ་ཚིག',
  PosCategory.preposition: 'ཚིག་ཕྲད',
  PosCategory.conjunction: 'འབྲེལ་ཚིག',
};
