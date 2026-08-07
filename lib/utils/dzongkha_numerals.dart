/// Converts an integer to Dzongkha (Tibetan-script) numerals.
///
/// Tibetan digits 0-9 occupy a contiguous Unicode block, U+0F20 ('༠')
/// through U+0F29 ('༩'), in the same order as ASCII '0'-'9'. So this is
/// the same trick `int.toString()` effectively does for Arabic numerals --
/// take each decimal digit and shift it into the target block -- rather
/// than a hardcoded table of number-words per value. Works for any
/// non-negative integer, not just a fixed range.
const _asciiZero = 0x30; // '0'
const _tibetanZero = 0x0F20; // '༠'

String toDzongkhaNumeral(int value) {
  assert(value >= 0, 'toDzongkhaNumeral does not support negative numbers');
  return value.toString().split('').map((digitChar) {
    final digit = digitChar.codeUnitAt(0) - _asciiZero;
    return String.fromCharCode(_tibetanZero + digit);
  }).join();
}
