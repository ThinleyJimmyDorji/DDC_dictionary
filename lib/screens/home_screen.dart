import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'search_tab.dart';
import 'settings_tab.dart';

/// Root shell: search is the primary destination (index 0), not buried
/// behind an extra tap like it was in the old 3-tab layout.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _tabs = [SearchTab(), SettingsTab()];

  static const _destinations = [
    AppNavDestination(
        icon: Icons.search_outlined,
        selectedIcon: Icons.search,
        label: 'Search'),
    AppNavDestination(
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: _tabs),
      ),
      bottomNavigationBar: AppBottomNav(
        destinations: _destinations,
        selectedIndex: _index,
        onSelect: (value) => setState(() => _index = value),
      ),
    );
  }
}
