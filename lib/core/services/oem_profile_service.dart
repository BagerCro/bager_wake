import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/diagnostic_item.dart';
import '../models/oem_profile.dart';

/// Loads the per-brand fix guides and resolves their settings shortcuts.
///
/// Profiles live in `assets/oem_profiles.json` rather than in code so a brand can
/// be corrected or added without touching Dart.
class OemProfileService {
  static const _channel = MethodChannel('com.tesic.bager_wake/intents');
  static const _assetPath = 'assets/oem_profiles.json';

  List<OemProfile>? _cache;

  Future<List<OemProfile>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, Object?>;
    _cache = (decoded['profiles'] as List)
        .cast<Map<String, Object?>>()
        .map(OemProfile.fromJson)
        .toList();
    return _cache!;
  }

  /// Matches [info] against the profiles, falling back to the `generic` profile
  /// when the brand is unknown.
  Future<OemProfile> profileFor(DeviceInfo info) async {
    final profiles = await loadAll();
    final needles = {
      info.manufacturer.toLowerCase(),
      info.brand.toLowerCase(),
    };
    for (final profile in profiles) {
      if (profile.manufacturerMatches
          .any((m) => needles.contains(m.toLowerCase()))) {
        return profile;
      }
    }
    return profiles.firstWhere((p) => p.id == 'generic');
  }

  /// Tries each candidate in order, checking `canResolveActivity` first, and
  /// returns the index that launched — or null when none of them resolved.
  Future<int?> launchStep(FixStep step) async {
    for (var i = 0; i < step.intents.length; i++) {
      final candidate = step.intents[i];
      final launched = await _channel.invokeMethod<bool>('launchIntent', {
            'action': candidate.action,
            'package': candidate.package,
            'component': candidate.component,
            'usesPackageData': candidate.usesPackageData,
          }) ??
          false;
      if (launched) return i;
    }
    return null;
  }
}
