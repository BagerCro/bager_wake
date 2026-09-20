import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/bulk_fix_service.dart';
import 'core/services/diagnostics_service.dart';
import 'core/services/important_apps_service.dart';
import 'core/services/oem_profile_service.dart';
import 'core/services/test_engine_service_impl.dart';
import 'features/shell/app_services.dart';

void main() {
  runApp(
    BagerWakeApp(
      services: AppServices(
        diagnostics: const DiagnosticsService(),
        oemProfiles: OemProfileService(),
        testEngine: const NativeTestEngineService(),
        bulkFix: const BulkFixService(),
        importantApps: ImportantAppsService(),
      ),
    ),
  );
}
