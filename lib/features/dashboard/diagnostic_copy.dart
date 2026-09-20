import 'package:flutter/material.dart';

import '../../core/services/diagnostics_service.dart';
import '../../l10n/generated/app_localizations.dart';

/// Plain-language title + one-liner for a diagnostic id. Kept as data here
/// rather than on [DiagnosticItem] itself, since the model only carries the
/// measured state, not display copy.
class DiagnosticCopy {
  const DiagnosticCopy({required this.title, required this.description, required this.icon});

  final String title;
  final String description;
  final IconData icon;
}

DiagnosticCopy diagnosticCopyFor(BuildContext context, String id) {
  final l10n = AppLocalizations.of(context);
  switch (id) {
    case DiagnosticIds.batteryOptimization:
      return DiagnosticCopy(
        title: l10n.diagBatteryOptimizationTitle,
        description: l10n.diagBatteryOptimizationDesc,
        icon: Icons.battery_charging_full,
      );
    case DiagnosticIds.notificationsEnabled:
      return DiagnosticCopy(
        title: l10n.diagNotificationsEnabledTitle,
        description: l10n.diagNotificationsEnabledDesc,
        icon: Icons.notifications_active_outlined,
      );
    case DiagnosticIds.exactAlarmPermission:
      return DiagnosticCopy(
        title: l10n.diagExactAlarmPermissionTitle,
        description: l10n.diagExactAlarmPermissionDesc,
        icon: Icons.alarm_on_outlined,
      );
    case DiagnosticIds.backgroundRestricted:
      return DiagnosticCopy(
        title: l10n.diagBackgroundRestrictedTitle,
        description: l10n.diagBackgroundRestrictedDesc,
        icon: Icons.block,
      );
    case DiagnosticIds.standbyBucket:
      return DiagnosticCopy(
        title: l10n.diagStandbyBucketTitle,
        description: l10n.diagStandbyBucketDesc,
        icon: Icons.layers_outlined,
      );
    case DiagnosticIds.dataSaver:
      return DiagnosticCopy(
        title: l10n.diagDataSaverTitle,
        description: l10n.diagDataSaverDesc,
        icon: Icons.data_saver_on_outlined,
      );
    case DiagnosticIds.powerSaveMode:
      return DiagnosticCopy(
        title: l10n.diagPowerSaveModeTitle,
        description: l10n.diagPowerSaveModeDesc,
        icon: Icons.battery_saver_outlined,
      );
    case DiagnosticIds.dozeState:
      return DiagnosticCopy(
        title: l10n.diagDozeStateTitle,
        description: l10n.diagDozeStateDesc,
        icon: Icons.bedtime_outlined,
      );
    default:
      // Defensive fallback only — every id in DiagnosticIds.all is handled above.
      return DiagnosticCopy(title: id, description: '', icon: Icons.help_outline);
  }
}
