import 'package:flutter/material.dart';

import '../../../core/models/diagnostic_item.dart';
import '../../../l10n/generated/app_localizations.dart';

class DeviceHeader extends StatelessWidget {
  const DeviceHeader({super.key, required this.device});

  final DeviceInfo? device;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final device = this.device;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.smartphone, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device == null
                        ? l10n.dashboardUnknownDevice
                        : '${device.brand} ${device.model}'.trim(),
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device == null
                        ? ''
                        : l10n.dashboardDeviceSubtitle(device.androidRelease, device.sdkInt),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
