import 'package:flutter/material.dart';

import '../../core/models/bulk_fix_app_status.dart';
import '../../core/models/important_app_ref.dart';
import '../../core/models/oem_profile.dart';
import '../../core/services/bulk_fix_service.dart';
import '../../core/services/diagnostics_service.dart';
import '../../core/services/important_apps_service.dart';
import '../../core/services/oem_profile_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../fix_guide/widgets/fix_step_card.dart';
import 'widgets/bulk_fix_app_tile.dart';

/// "Popravi sve" tab: a guided, one-by-one checklist for other apps' battery
/// exemption plus a manual autostart checklist. There is deliberately no bulk
/// auto-fix button — Android gives a normal app no way to grant another app's
/// exemption, only to read it and open that app's own settings screen.
class BulkFixScreen extends StatefulWidget {
  const BulkFixScreen({
    super.key,
    required this.bulkFixService,
    required this.importantAppsService,
    required this.oemProfileService,
    required this.diagnostics,
  });

  final BulkFixService bulkFixService;
  final ImportantAppsService importantAppsService;
  final OemProfileService oemProfileService;
  final DiagnosticsService diagnostics;

  @override
  State<BulkFixScreen> createState() => _BulkFixScreenState();
}

class _BulkFixScreenState extends State<BulkFixScreen> with WidgetsBindingObserver {
  late Future<_BulkFixData> _future;

  // Gate the lifecycle re-check on a completed first load, so a resume that
  // fires while the initial fetch is still in flight doesn't race it.
  bool _hasLoadedOnce = false;

  final Set<String> _confirmedStepKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from an app-details screen the user just changed by hand is
    // exactly when the read is worth redoing — nothing else in this app
    // watches lifecycle resume today.
    if (state == AppLifecycleState.resumed && _hasLoadedOnce && mounted) {
      _recheckStatuses();
    }
  }

  Future<_BulkFixData> _load() async {
    final importantRefs = await widget.importantAppsService.loadAll();
    final installed = await widget.bulkFixService.listInstalledApps();
    final device = await widget.diagnostics.readDeviceInfo();
    final profile = await widget.oemProfileService.profileFor(device);

    final installedByPackage = {for (final a in installed) a.package: a};

    final curatedRefs = importantRefs
        .where((ref) => installedByPackage.containsKey(ref.package))
        .toList();
    final curatedPackages = curatedRefs.map((r) => r.package).toSet();

    final otherApps = installed
        .where((a) => !curatedPackages.contains(a.package))
        .toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

    final statuses = await widget.bulkFixService.isIgnoringBatteryOptimizationsBatch([
      ...curatedPackages,
      ...otherApps.map((a) => a.package),
    ]);

    final curated = curatedRefs
        .map((ref) => BulkFixAppEntry(
              package: ref.package,
              displayLabel: ref.nameHr,
              category: ref.category,
              isCurated: true,
              status: _statusOf(statuses, ref.package),
            ))
        .toList();

    final others = otherApps
        .map((a) => BulkFixAppEntry(
              package: a.package,
              displayLabel: a.label,
              category: AppCategory.other,
              isCurated: false,
              status: _statusOf(statuses, a.package),
            ))
        .toList();

    _hasLoadedOnce = true;
    return _BulkFixData(curated: curated, others: others, profile: profile);
  }

  BulkFixStatus _statusOf(Map<String, bool?> statuses, String package) {
    final value = statuses[package];
    if (value == null) return BulkFixStatus.unavailable;
    return value ? BulkFixStatus.exempt : BulkFixStatus.notExempt;
  }

  Future<void> _refresh() async {
    final next = _load();
    final data = await next;
    if (!mounted) return;
    setState(() => _future = Future.value(data));
  }

  Future<void> _recheckStatuses() async {
    final current = await _future;
    final packages = [
      ...current.curated.map((e) => e.package),
      ...current.others.map((e) => e.package),
    ];
    final statuses =
        await widget.bulkFixService.isIgnoringBatteryOptimizationsBatch(packages);
    if (!mounted) return;
    setState(() {
      _future = Future.value(_BulkFixData(
        curated: current.curated
            .map((e) => e.copyWith(status: _statusOf(statuses, e.package)))
            .toList(),
        others: current.others
            .map((e) => e.copyWith(status: _statusOf(statuses, e.package)))
            .toList(),
        profile: current.profile,
      ));
    });
  }

  Future<void> _openAppDetails(String package) async {
    await widget.bulkFixService.openAppDetailsFor(package);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bulkFixTitle)),
      body: FutureBuilder<_BulkFixData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: l10n.bulkFixLoadError,
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final data = snapshot.data!;
          final theme = Theme.of(context);
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _IntroCard(text: l10n.bulkFixIntro),
                const SizedBox(height: 8),
                _SectionHeader(title: l10n.bulkFixSectionImportant),
                for (final category in AppCategory.values)
                  ..._buildCategoryGroup(context, data.curated, category),
                if (data.curated.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      l10n.bulkFixNoImportantInstalled,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ExpansionTile(
                    title: Text(l10n.bulkFixSectionOthers),
                    initiallyExpanded: false,
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    children: [
                      if (data.others.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            l10n.bulkFixEmptyOthers,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        )
                      else
                        for (final entry in data.others)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: BulkFixAppTile(
                              entry: entry,
                              onCheckSettings: () => _openAppDetails(entry.package),
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _SectionHeader(title: l10n.bulkFixSectionAutostart),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.bulkFixAutostartExplainer,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 8),
                for (final entry in data.curated)
                  if (data.profile.steps.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.displayLabel, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 6),
                          for (var i = 0; i < data.profile.steps.length; i++)
                            FixStepCard(
                              index: i + 1,
                              step: data.profile.steps[i],
                              appName: entry.displayLabel,
                              confirmed: _confirmedStepKeys
                                  .contains('${entry.package}::${data.profile.steps[i].id}'),
                              onConfirmedChanged: (v) => setState(() {
                                final key = '${entry.package}::${data.profile.steps[i].id}';
                                if (v) {
                                  _confirmedStepKeys.add(key);
                                } else {
                                  _confirmedStepKeys.remove(key);
                                }
                              }),
                              onLaunch: () => widget.oemProfileService
                                  .launchStep(data.profile.steps[i]),
                            ),
                        ],
                      ),
                    ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCategoryGroup(
    BuildContext context,
    List<BulkFixAppEntry> curated,
    AppCategory category,
  ) {
    final entries = curated.where((e) => e.category == category).toList();
    if (entries.isEmpty) return const [];
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final label = switch (category) {
      AppCategory.messaging => l10n.bulkFixCategoryMessaging,
      AppCategory.banking => l10n.bulkFixCategoryBanking,
      AppCategory.calendar => l10n.bulkFixCategoryCalendar,
      AppCategory.other => l10n.bulkFixCategoryOther,
    };
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(
          label,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700),
        ),
      ),
      for (final entry in entries)
        BulkFixAppTile(
          entry: entry,
          onCheckSettings: () => _openAppDetails(entry.package),
        ),
    ];
  }
}

class _BulkFixData {
  const _BulkFixData({required this.curated, required this.others, required this.profile});
  final List<BulkFixAppEntry> curated;
  final List<BulkFixAppEntry> others;
  final OemProfile profile;
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}
