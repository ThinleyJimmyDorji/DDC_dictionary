import 'package:flutter/material.dart';

/// Hand-picked design tokens, not a `ColorScheme.fromSeed()` tonal ramp.
///
/// The seeded Material 3 palette (and its default Card-heavy component
/// theming) is what every other Flutter app looks like out of the box.
/// This app is a reference tool people reach for constantly, so the
/// surfaces are deliberately flat -- hairline dividers instead of
/// elevated cards, generous type, and color spent only on things that
/// need to be found at a glance (the part-of-speech badge, the active
/// nav item).
class AppColors {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.accent,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
  });

  final Color background;
  final Color surface;

  /// Subtle fill for sections that need to stand apart from the list
  /// without a border/shadow (Word of the Day band, sheet header).
  final Color surfaceAlt;

  final Color accent;
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;

  static const light = AppColors(
    background: Color(0xFFFBF7F2),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1E9DC),
    accent: Color(0xFFC1602A),
    onAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF241C15),
    textSecondary: Color(0xFF6B5D4F),
    divider: Color(0xFFE7DDCF),
  );

  static const dark = AppColors(
    background: Color(0xFF15110D),
    surface: Color(0xFF1C1712),
    surfaceAlt: Color(0xFF241D16),
    accent: Color(0xFFEA9F52),
    onAccent: Color(0xFF1C1712),
    textPrimary: Color(0xFFF5EFE6),
    textSecondary: Color(0xFFB9AC9B),
    divider: Color(0xFF332A21),
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      primaryContainer: c.surfaceAlt,
      onPrimaryContainer: c.accent,
      secondary: c.accent,
      onSecondary: c.onAccent,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceAlt,
      onSurfaceVariant: c.textSecondary,
      outline: c.textSecondary,
      outlineVariant: c.divider,
      error: brightness == Brightness.light
          ? const Color(0xFFB3261E)
          : const Color(0xFFE2726B),
      onError: Colors.white,
    );

    final baseTextTheme = ThemeData(brightness: brightness).textTheme;
    final textTheme = baseTextTheme.apply(
      bodyColor: c.textPrimary,
      displayColor: c.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.divider,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
      ),
      cardTheme: const CardThemeData(elevation: 0, color: Colors.transparent),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        labelStyle:
            TextStyle(color: c.textPrimary, fontWeight: FontWeight.w500),
        side: BorderSide(color: c.divider),
        shape: const StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceAlt,
        hintStyle: TextStyle(color: c.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.accent,
        thumbColor: c.accent,
        inactiveTrackColor: c.divider,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: c.divider)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? c.accent
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? c.onAccent
                : c.textPrimary,
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionColor: c.accent.withValues(alpha: 0.28),
        selectionHandleColor: c.accent,
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
