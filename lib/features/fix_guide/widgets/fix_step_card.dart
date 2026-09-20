import 'package:flutter/material.dart';

import '../../../core/models/oem_profile.dart';
import '../../../l10n/generated/app_localizations.dart';

class FixStepCard extends StatelessWidget {
  const FixStepCard({
    super.key,
    required this.index,
    required this.step,
    required this.confirmed,
    required this.onConfirmedChanged,
    required this.onLaunch,
  });

  final int index;
  final FixStep step;
  final bool confirmed;
  final ValueChanged<bool> onConfirmedChanged;
  final Future<void> Function() onLaunch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isHr = Localizations.localeOf(context).languageCode == 'hr';
    final title = isHr ? step.titleHr : step.titleEn;
    final body = isHr ? step.bodyHr : step.bodyEn;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium),
            if (step.intents.isNotEmpty) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onLaunch,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(l10n.commonOpenSettings),
              ),
            ],
            if (step.requiresManualConfirm) ...[
              const SizedBox(height: 4),
              CheckboxListTile(
                value: confirmed,
                onChanged: (v) => onConfirmedChanged(v ?? false),
                title: Text(l10n.fixGuideConfirmCheckbox),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
