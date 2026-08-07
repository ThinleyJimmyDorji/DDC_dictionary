import 'package:flutter/material.dart';

import '../utils/responsive.dart';

class AppNavDestination {
  const AppNavDestination(
      {required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Flat two-item bottom bar: a thin top divider and an accent-colored
/// icon/label for the active tab, no filled pill indicator behind it.
///
/// Shares the same width as the content above it (via [ContentBounds]'
/// default), so its edges line up with the search field and result rows
/// instead of floating narrower underneath them.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<AppNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Responsive.isTablet(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border:
            Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: isTablet ? 68 : 60,
          child: ContentBounds(
            child: Row(
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _NavItem(
                      destination: destinations[i],
                      selected: i == selectedIndex,
                      onTap: () => onSelect(i),
                      isTablet: isTablet,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.isTablet,
  });

  final AppNavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        selected ? theme.colorScheme.primary : theme.colorScheme.outline;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? destination.selectedIcon : destination.icon,
              color: color, size: isTablet ? 26 : 24),
          const SizedBox(height: 4),
          Text(
            destination.label,
            style: (isTablet
                    ? theme.textTheme.labelMedium
                    : theme.textTheme.labelSmall)
                ?.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
