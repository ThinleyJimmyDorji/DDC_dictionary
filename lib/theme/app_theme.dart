import 'package:flutter/material.dart';

/// Material 3 theme, light and dark, seeded from the DDC's orange brand
/// color (kept from the original app).
///
/// Design choice: unlike the old app, the *global* font family is left as
/// the platform default -- UI chrome (buttons, nav labels, settings) reads
/// better in a font actually designed for Latin UI text. Jomolhari (the
/// Tibetan-script font) is applied selectively, via [dzongkhaTextStyle],
/// wherever actual Dzongkha content is shown. The old app set
/// `fontFamily: 'jomolhari'` app-wide, which made every English label use
/// a Tibetan-script font unnecessarily.
class AppTheme {
  AppTheme._();

  static const Color seedColor = Colors.orange;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Text style for Dzongkha (Tibetan script) content: the Jomolhari font,
/// with the extra line height / letter / word spacing the script needs to
/// stay legible (stacked consonant clusters need more vertical room than
/// Latin text), scaled by the user's chosen text-size preference.
TextStyle dzongkhaTextStyle({
  required double baseSize,
  double textScale = 1.0,
  FontWeight fontWeight = FontWeight.normal,
  Color? color,
  double height = 1.9,
}) {
  return TextStyle(
    fontFamily: 'jomolhari',
    fontSize: baseSize * textScale,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: 0.4,
    wordSpacing: 3,
  );
}
