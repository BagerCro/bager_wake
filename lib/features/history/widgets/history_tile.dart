import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../core/models/test_run.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/status_visuals.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.run, required this.onTap});

  final TestRun run;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // screenUnlockedDuringTest is bool? — null means unknown, not clean.
    final screenUnlocked = run.screenUnlockedDuringTest;
    final isDirty = screenUnlocked == true || run.rebootedDuringTest;
    final isUnknownClean = screenUnlocked == null && !run.rebootedDuringTest;
    final dateFormat = DateFormat('d.M.yyyy. HH:mm');

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(dateFormat.format(run.startedAt),
                        style: theme.textTheme.titleSmall),
                  ),
                  if (isDirty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.historyDirtyTag,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onErrorContainer),
                      ),
                    )
                  else if (isUnknownClean)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.historyUnknownTag,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.historyWindowLabel(run.window.inMinutes),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final lane in run.lanes) StatusChip(visual: laneOutcomeVisual(context, lane.outcome)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
