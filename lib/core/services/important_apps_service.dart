import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/important_app_ref.dart';

/// Loads the curated list of important third-party apps (messaging, banking,
/// calendar) the bulk-fix screen specifically calls out.
///
/// The list lives in `assets/important_apps.json` rather than in code so it
/// can be corrected or extended without touching Dart.
class ImportantAppsService {
  static const _assetPath = 'assets/important_apps.json';

  List<ImportantAppRef>? _cache;

  Future<List<ImportantAppRef>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, Object?>;
    _cache = (decoded['apps'] as List)
        .cast<Map<String, Object?>>()
        .map(ImportantAppRef.fromJson)
        .toList();
    return _cache!;
  }
}
