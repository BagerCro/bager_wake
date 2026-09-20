import '../../core/services/diagnostics_service.dart';
import '../../core/services/oem_profile_service.dart';
import '../../core/services/test_engine_service.dart';

/// Bundles the app's service dependencies so screens take them as plain
/// constructor arguments instead of reaching for a DI package that isn't
/// in pubspec.yaml.
class AppServices {
  const AppServices({
    required this.diagnostics,
    required this.oemProfiles,
    required this.testEngine,
  });

  final DiagnosticsService diagnostics;
  final OemProfileService oemProfiles;
  final TestEngineService testEngine;
}
