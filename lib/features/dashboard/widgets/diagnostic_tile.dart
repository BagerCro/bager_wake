import 'package:flutter/material.dart';

import '../../../core/models/diagnostic_item.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/status_visuals.dart';
import '../diagnostic_copy.dart';

class DiagnosticTile extends StatelessWidget {
  const DiagnosticTile({
    super.key,
    required this.item,
    required this.onOpenSettings,
    this.onRequestNotificationPermission,
  });

  final DiagnosticItem item;
  final VoidCallback onOpenSettings;
  final VoidCallback? onRequestNotificationPermission;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final copy = diagnosticCopyFor(context, item.id);
    final visual = diagnosticStatusVisual(context, item.status);
    final isUnavailable = item.status == DiagnosticStatus.unavailable;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      // Unavailable gets a dashed-feeling outlined treatment instead of the
      // solid tint the other three statuses get — it must never look like a
      // calm, resolved tile.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnavailable
            ? BorderSide(color: visual.color.withValues(alpha: 0.6), width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(copy.icon, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(copy.title, style: theme.textTheme.titleMedium),
                ),
                const SizedBox(width: 8),
                StatusChip(visual: visual),
              ],
            ),
            const SizedBox(height: 8),
            Text(copy.description, style: theme.textTheme.bodyMedium),
            if (isUnavailable) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: visual.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: visual.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(color: visual.color),
                          children: [
                            TextSpan(
                              text: '${l10n.unavailableReasonLabel}: ',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: item.unavailableReason?.isNotEmpty == true
                                  ? item.unavailableReason
                                  : l10n.unavailableReasonFallback,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (item.hasSettingsShortcut || onRequestNotificationPermission != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (item.hasSettingsShortcut)
                    OutlinedButton.icon(
                      onPressed: onOpenSettings,
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: Text(l10n.commonOpenSettings),
                    ),
                  if (onRequestNotificationPermission != null)
                    TextButton(
                      onPressed: onRequestNotificationPermission,
                      child: Text(l10n.dashboardNotifPermButton),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
