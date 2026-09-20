import 'package:flutter_test/flutter_test.dart';

import 'package:bager_wake/app.dart';
import 'package:bager_wake/core/services/diagnostics_service.dart';
import 'package:bager_wake/core/services/oem_profile_service.dart';
import 'package:bager_wake/features/dev/dev_test_engine_service.dart';
import 'package:bager_wake/features/shell/app_services.dart';

void main() {
  testWidgets('App boots without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(
      BagerWakeApp(
        services: AppServices(
          diagnostics: const DiagnosticsService(),
          oemProfiles: OemProfileService(),
          testEngine: DevTestEngineService(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(BagerWakeApp), findsOneWidget);
  });
}
