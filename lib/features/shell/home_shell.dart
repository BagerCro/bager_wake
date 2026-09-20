import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../about/about_screen.dart';
import '../bulk_fix/bulk_fix_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../fix_guide/fix_guide_screen.dart';
import '../history/history_screen.dart';
import '../test/test_screen.dart';
import 'app_services.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.services});

  final AppServices services;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // IndexedStack keeps each tab's state alive (e.g. an in-progress test's
    // countdown) when switching tabs instead of rebuilding from scratch.
    final screens = [
      DashboardScreen(diagnostics: widget.services.diagnostics),
      TestScreen(
        testEngine: widget.services.testEngine,
        onNeedPermissions: () => _goToTab(0),
      ),
      FixGuideScreen(
        diagnostics: widget.services.diagnostics,
        oemProfiles: widget.services.oemProfiles,
      ),
      HistoryScreen(testEngine: widget.services.testEngine),
      BulkFixScreen(
        bulkFixService: widget.services.bulkFix,
        importantAppsService: widget.services.importantApps,
        oemProfileService: widget.services.oemProfiles,
        diagnostics: widget.services.diagnostics,
      ),
      const AboutScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goToTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.science_outlined),
            selectedIcon: const Icon(Icons.science),
            label: l10n.navTest,
          ),
          NavigationDestination(
            icon: const Icon(Icons.build_outlined),
            selectedIcon: const Icon(Icons.build),
            label: l10n.navFixGuide,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist),
            label: l10n.navBulkFix,
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            label: l10n.navAbout,
          ),
        ],
      ),
    );
  }
}
