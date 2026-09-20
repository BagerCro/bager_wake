import 'package:flutter/material.dart';

import '../../core/models/diagnostic_item.dart';
import '../../core/models/test_run.dart';
import '../../l10n/generated/app_localizations.dart';

/// Icon + color + text label for a status. Never color alone — hue-blind
/// users and the "unavailable" honesty rule both depend on the label and icon
/// carrying the meaning too.
class StatusVisual {
  const StatusVisual({required this.color, required this.icon, required this.label});

  final Color color;
  final IconData icon;
  final String label;
}

StatusVisual diagnosticStatusVisual(BuildContext context, DiagnosticStatus status) {
  final l10n = AppLocalizations.of(context);
  final dark = Theme.of(context).brightness == Brightness.dark;
  switch (status) {
    case DiagnosticStatus.ok:
      return StatusVisual(
        color: dark ? const Color(0xFF8BD99F) : const Color(0xFF1E7A3D),
        icon: Icons.check_circle,
        label: l10n.statusOk,
      );
    case DiagnosticStatus.warning:
      return StatusVisual(
        color: dark ? const Color(0xFFFFC77D) : const Color(0xFFAD5C00),
        icon: Icons.warning_amber_rounded,
        label: l10n.statusWarning,
      );
    case DiagnosticStatus.problem:
      return StatusVisual(
        color: dark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
        icon: Icons.error,
        label: l10n.statusProblem,
      );
    case DiagnosticStatus.unavailable:
      // Deliberately not grey: grey reads as "neutral / probably fine" and this
      // status means the opposite — the app knows nothing here.
      return StatusVisual(
        color: dark ? const Color(0xFFC3B8FF) : const Color(0xFF5B4CB3),
        icon: Icons.help_outline,
        label: l10n.statusUnavailable,
      );
  }
}

StatusVisual laneOutcomeVisual(BuildContext context, LaneOutcome outcome) {
  final l10n = AppLocalizations.of(context);
  final dark = Theme.of(context).brightness == Brightness.dark;
  switch (outcome) {
    case LaneOutcome.pending:
      return StatusVisual(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        icon: Icons.hourglass_top,
        label: l10n.outcomePending,
      );
    case LaneOutcome.firedOnTime:
      return StatusVisual(
        color: dark ? const Color(0xFF8BD99F) : const Color(0xFF1E7A3D),
        icon: Icons.check_circle,
        label: l10n.outcomeFiredOnTime,
      );
    case LaneOutcome.firedLate:
      return StatusVisual(
        color: dark ? const Color(0xFFFFC77D) : const Color(0xFFAD5C00),
        icon: Icons.schedule,
        label: l10n.outcomeFiredLate,
      );
    case LaneOutcome.neverFired:
      return StatusVisual(
        color: dark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
        icon: Icons.cancel,
        label: l10n.outcomeNeverFired,
      );
    case LaneOutcome.cancelled:
      return StatusVisual(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        icon: Icons.block,
        label: l10n.outcomeCancelled,
      );
  }
}

/// Compact pill combining icon + label, always paired with [color] so status
/// never depends on hue alone.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.visual});

  final StatusVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: visual.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: visual.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(visual.icon, size: 16, color: visual.color),
          const SizedBox(width: 6),
          Text(
            visual.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: visual.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
