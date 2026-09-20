import 'package:flutter/services.dart';

/// A single installed app as reported by the platform's PackageManager scan.
class InstalledApp {
  final String package;
  final String label;

  const InstalledApp({required this.package, required this.label});
}

/// Thrown when the underlying app-listing query itself failed — distinct from
/// a real empty list (zero apps installed is a valid reading).
class BulkFixListUnavailable implements Exception {}

/// Reads other installed apps' battery-optimization exemption state and opens
/// Settings for the user to change it by hand. A normal app can never write
/// another app's exemption, so every reading here is exactly what the
/// platform reports right now — a failed read is `null`, never coerced to
/// `false`.
class BulkFixService {
  static const _channel = MethodChannel('com.tesic.bager_wake/bulk_fix');

  const BulkFixService();

  Future<List<InstalledApp>> listInstalledApps() async {
    final raw =
        await _channel.invokeMapMethod<Object?, Object?>('listInstalledApps');
    final map = (raw ?? const {}).cast<String, Object?>();
    final ok = map['ok'] as bool? ?? false;
    if (!ok) throw BulkFixListUnavailable();
    final apps = (map['apps'] as List? ?? const [])
        .cast<Map<Object?, Object?>>()
        .map((e) {
      final entry = e.cast<String, Object?>();
      return InstalledApp(
        package: entry['package'] as String? ?? '',
        label: entry['label'] as String? ?? '',
      );
    }).toList();
    return apps;
  }

  /// null = could not determine this package's state. Never coerced to false.
  Future<bool?> isIgnoringBatteryOptimizations(String package) async {
    return _channel.invokeMethod<bool>(
      'isIgnoringBatteryOptimizations',
      {'package': package},
    );
  }

  /// One round trip for many packages. Missing/failed entries map to null,
  /// never false.
  Future<Map<String, bool?>> isIgnoringBatteryOptimizationsBatch(
    List<String> packages,
  ) async {
    final raw = await _channel.invokeMapMethod<Object?, Object?>(
      'isIgnoringBatteryOptimizationsBatch',
      {'packages': packages},
    );
    final map = (raw ?? const {}).cast<String, Object?>();
    return {
      for (final package in packages) package: map[package] as bool?,
    };
  }

  Future<bool> openAppDetailsFor(String package) async {
    return await _channel.invokeMethod<bool>(
          'openAppDetailsFor',
          {'package': package},
        ) ??
        false;
  }
}
