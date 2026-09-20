import 'package:flutter/material.dart';

import '../../../core/models/bulk_fix_app_status.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/status_visuals.dart';

/// Row for one app in the bulk-fix list. Mirrors [StatusChip]'s icon+color+
/// label language from the dashboard's diagnostic tiles, so the same status
/// never reads differently across the two screens.
class BulkFixAppTile extends StatelessWidget {
  const BulkFixAppTile({
    super.key,
    required this.entry,
    required this.onCheckSettings,
  });

  final BulkFixAppEntry entry;
  final Future<void> Function() onCheckSettings;

  StatusVisual _visualFor(BuildContext context, BulkFixStatus status) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case BulkFixStatus.exempt:
        return StatusVisual(
          color: dark ? const Color(0xFF8BD99F) : const Color(0xFF1E7A3D),
          icon: Icons.check_circle,
          label: l10n.bulkFixStatusExempt,
        );
      case BulkFixStatus.notExempt:
        return StatusVisual(
          color: dark ? const Color(0xFFFFC77D) : const Color(0xFFAD5C00),
          icon: Icons.warning_amber_rounded,
          label: l10n.bulkFixStatusNotExempt,
        );
      case BulkFixStatus.unavailable:
        // Same deliberately-not-grey purple as DiagnosticStatus.unavailable:
        // an unknown read must never look like a calm, resolved state.
        return StatusVisual(
          color: dark ? const Color(0xFFC3B8FF) : const Color(0xFF5B4CB3),
          icon: Icons.help_outline,
          label: l10n.bulkFixStatusUnknown,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final visual = _visualFor(context, entry.status);
    final isNotExempt = entry.status == BulkFixStatus.notExempt;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: entry.status == BulkFixStatus.unavailable
            ? BorderSide(color: visual.color.withValues(alpha: 0.6), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isNotExempt ? onCheckSettings : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.displayLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    StatusChip(visual: visual),
                  ],
                ),
              ),
              if (isNotExempt) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onCheckSettings,
                  child: Text(l10n.bulkFixCheckButton),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
