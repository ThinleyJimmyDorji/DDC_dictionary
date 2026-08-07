import 'package:flutter/material.dart';

/// Width-based breakpoints and helpers so the app reads comfortably on
/// phones, tablets, and desktop windows -- not just a phone screen
/// stretched wider. Keyed off `shortestSide` (not orientation), so a
/// device classifies the same way whether the app is held in portrait or
/// landscape.
class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;

  /// How wide the main content column gets. Phones get the full width
  /// (unchanged). Tablets/desktop get most of the available width rather
  /// than a flat cap -- a fixed ~720 cap left a large iPad mostly empty
  /// margin either side; this scales with the window instead, with a
  /// generous ceiling only for very wide desktop windows where a truly
  /// full-bleed line length would hurt readability.
  static double contentWidthFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < tabletBreakpoint) return width;
    final scaled = width * 0.94;
    return scaled > 980 ? 980 : scaled;
  }

  /// Extra type-scale bump for tablets/desktop, layered on top of the
  /// user's own font-size preference from Settings. Larger screens are
  /// typically held or viewed from further away, so the same logical point
  /// size reads relatively smaller there.
  static double fontBumpFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return 1.3;
    if (width >= tabletBreakpoint) return 1.2;
    return 1.0;
  }
}

/// Centers its child and caps its width on large screens, so text lines,
/// row layouts, and touch targets stay a comfortable reading width instead
/// of spanning edge-to-edge on a tablet or desktop window.
///
/// [maxWidth] defaults to [Responsive.contentWidthFor] when omitted, so
/// callers don't need to duplicate that calculation -- pass an explicit
/// value only when a narrower column is actually wanted.
class ContentBounds extends StatelessWidget {
  const ContentBounds({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: maxWidth ?? Responsive.contentWidthFor(context)),
        child: child,
      ),
    );
  }
}
