import 'package:flutter/material.dart';

import '../../core/models/oem_profile.dart';
import '../../core/services/diagnostics_service.dart';
import '../../core/services/oem_profile_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/fix_step_card.dart';

class FixGuideScreen extends StatefulWidget {
  const FixGuideScreen({
    super.key,
    required this.diagnostics,
    required this.oemProfiles,
  });

  final DiagnosticsService diagnostics;
  final OemProfileService oemProfiles;

  @override
  State<FixGuideScreen> createState() => _FixGuideScreenState();
}

class _FixGuideScreenState extends State<FixGuideScreen> {
  late Future<OemProfile> _future;
  final Set<String> _confirmedStepIds = {};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<OemProfile> _load() async {
    final device = await widget.diagnostics.readDeviceInfo();
    return widget.oemProfiles.profileFor(device);
  }

  Future<void> _launchStep(FixStep step) async {
    final index = await widget.oemProfiles.launchStep(step);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(index == null ? l10n.fixGuideOpenFailed : l10n.fixGuideOpenSucceeded),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.fixGuideTitle)),
      body: FutureBuilder<OemProfile>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: l10n.fixGuideLoadError,
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final profile = snapshot.data!;
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(profile.displayName, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                l10n.fixGuideAggressiveness(profile.aggressivenessRank),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (!profile.verified) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.science_outlined, color: theme.colorScheme.onTertiaryContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.fixGuideUnverified(profile.displayName),
                          style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (profile.steps.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(l10n.fixGuideNoSteps, textAlign: TextAlign.center),
                )
              else
                for (var i = 0; i < profile.steps.length; i++)
                  FixStepCard(
                    index: i + 1,
                    step: profile.steps[i],
                    confirmed: _confirmedStepIds.contains(profile.steps[i].id),
                    onConfirmedChanged: (v) => setState(() {
                      if (v) {
                        _confirmedStepIds.add(profile.steps[i].id);
                      } else {
                        _confirmedStepIds.remove(profile.steps[i].id);
                      }
                    }),
                    onLaunch: () => _launchStep(profile.steps[i]),
                  ),
            ],
          );
        },
      ),
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
