import 'package:flutter/services.dart';

import '../models/diagnostic_item.dart';

/// Stable ids for every restriction the dashboard shows. Keep in sync with the
/// Kotlin side and with the l10n keys that describe each one.
abstract final class DiagnosticIds {
  static const batteryOptimization = 'battery_optimization';
  static const notificationsEnabled = 'notifications_enabled';
  static const exactAlarmPermission = 'exact_alarm_permission';
  static const backgroundRestricted = 'background_restricted';
  static const standbyBucket = 'standby_bucket';
  static const dataSaver = 'data_saver';
  static const powerSaveMode = 'power_save_mode';
  static const dozeState = 'doze_state';

  static const all = [
    batteryOptimization,
    notificationsEnabled,
    exactAlarmPermission,
    backgroundRestricted,
    standbyBucket,
    dataSaver,
    powerSaveMode,
    dozeState,
  ];
}

/// Reads the real restriction state off the device. Every reading either comes
/// back with a value actually obtained from a platform API, or with
/// [DiagnosticStatus.unavailable] plus a reason — never a guess.
class DiagnosticsService {
  static const _channel = MethodChannel('com.tesic.bager_wake/diagnostics');

  const DiagnosticsService();

  Future<List<DiagnosticItem>> readAll() async {
    final raw = await _channel.invokeListMethod<Object?>('readAll') ?? const [];
    return raw
        .cast<Map<Object?, Object?>>()
        .map((e) => DiagnosticItem.fromMap(e.cast<String, Object?>()))
        .toList();
  }

  Future<DeviceInfo> readDeviceInfo() async {
    final raw = await _channel.invokeMapMethod<Object?, Object?>('deviceInfo');
    return DeviceInfo.fromMap((raw ?? const {}).cast<String, Object?>());
  }

  /// Opens the settings screen for [diagnosticId]. Returns false when no screen
  /// could be resolved, so the caller can tell the user to navigate by hand.
  Future<bool> openSettingsFor(String diagnosticId) async {
    return await _channel.invokeMethod<bool>(
          'openSettings',
          {'id': diagnosticId},
        ) ??
        false;
  }

  /// Requests POST_NOTIFICATIONS (API 33+). Returns the resulting grant state.
  Future<bool> requestNotificationPermission() async {
    return await _channel
            .invokeMethod<bool>('requestNotificationPermission') ??
        false;
  }
}
