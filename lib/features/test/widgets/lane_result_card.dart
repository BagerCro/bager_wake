import 'package:flutter/material.dart';

import '../../../core/models/test_run.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/status_visuals.dart';

class LaneResultCard extends StatelessWidget {
  const LaneResultCard({super.key, required this.result});

  final LaneResult result;

  static (String, String) _copy(AppLocalizations l10n, LaneId lane) => switch (lane) {
        LaneId.alarmClock => (l10n.laneAlarmClockTitle, l10n.laneAlarmClockDesc),
        LaneId.exactIdle => (l10n.laneExactIdleTitle, l10n.laneExactIdleDesc),
        LaneId.workManager => (l10n.laneWorkManagerTitle, l10n.laneWorkManagerDesc),
      };

  String _formatDelay(Duration d) {
    if (d.inMinutes >= 1) return '${d.inMinutes} min';
    return '${d.inSeconds} s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (title, desc) = _copy(l10n, result.lane);
    final visual = laneOutcomeVisual(context, result.outcome);
    final isBad = result.outcome == LaneOutcome.neverFired ||
        result.outcome == LaneOutcome.firedLate;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isBad
            ? BorderSide(color: visual.color.withValues(alpha: 0.6), width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
                StatusChip(visual: visual),
              ],
            ),
            const SizedBox(height: 6),
            Text(desc, style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            if (result.outcome == LaneOutcome.firedLate && result.delay != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.outcomeDelay(_formatDelay(result.delay!)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: visual.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
