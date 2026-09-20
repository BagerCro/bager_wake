// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BagerWake';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navTest => 'Test';

  @override
  String get navFixGuide => 'Fix guide';

  @override
  String get navHistory => 'History';

  @override
  String get navAbout => 'About';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonOpenSettings => 'Open settings';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonError => 'Something went wrong.';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get statusOk => 'OK';

  @override
  String get statusWarning => 'Warning';

  @override
  String get statusProblem => 'Problem';

  @override
  String get statusUnavailable => 'Can\'t be checked';

  @override
  String get unavailableReasonLabel => 'Reason';

  @override
  String get unavailableReasonFallback =>
      'The app didn\'t get a reason from the system.';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String dashboardDeviceSubtitle(String release, int sdk) {
    return 'Android $release · API $sdk';
  }

  @override
  String get dashboardLoadError =>
      'Couldn\'t read the device state. Make sure the app has permission and try again.';

  @override
  String get dashboardUnknownDevice => 'Unknown device';

  @override
  String get dashboardNotifPermButton => 'Request permission';

  @override
  String get diagBatteryOptimizationTitle => 'Battery optimization';

  @override
  String get diagBatteryOptimizationDesc =>
      'If the app is under \'battery optimization\', the system shuts down its background work when you\'re not using it — notifications and alarms can be delayed or never arrive.';

  @override
  String get diagNotificationsEnabledTitle => 'Notification permission';

  @override
  String get diagNotificationsEnabledDesc =>
      'Without this permission the system doesn\'t show the app\'s notifications at all, no matter what else is configured.';

  @override
  String get diagExactAlarmPermissionTitle => 'Exact alarm permission';

  @override
  String get diagExactAlarmPermissionDesc =>
      'Without this permission Android is allowed to push an alarm later instead of ringing it exactly when it was scheduled.';

  @override
  String get diagBackgroundRestrictedTitle => 'Background work restricted';

  @override
  String get diagBackgroundRestrictedDesc =>
      'When this is on, the system almost completely blocks the app from running while you\'re not looking at it — notifications usually don\'t arrive at all.';

  @override
  String get diagStandbyBucketTitle => 'Activity group (App Standby)';

  @override
  String get diagStandbyBucketDesc =>
      'Android sorts apps into groups based on how much you use them. A worse group gets fewer chances to run in the background, so notifications are delayed.';

  @override
  String get diagDataSaverTitle => 'Data saver';

  @override
  String get diagDataSaverDesc =>
      'When it\'s on, background apps aren\'t allowed to use mobile data — messages and sync wait until you open the app yourself.';

  @override
  String get diagPowerSaveModeTitle => 'Battery saver mode';

  @override
  String get diagPowerSaveModeDesc =>
      'This mode further throttles background work and delays alarms and notifications while it\'s on, to stretch battery life.';

  @override
  String get diagDozeStateTitle => 'Doze (idle state)';

  @override
  String get diagDozeStateDesc =>
      'When the phone sits untouched for a while, Android periodically \'puts all apps to sleep\' — notifications get batched and arrive in bursts instead of right away.';

  @override
  String get testTitle => 'Delivery test';

  @override
  String get testWindowLabel => 'Test duration';

  @override
  String get testWindow15 => '15 min';

  @override
  String get testWindow30 => '30 min';

  @override
  String get testWindow60 => '60 min';

  @override
  String get testPreflightTitle => 'Before you start';

  @override
  String get testPreflightBody =>
      'Lock the screen, don\'t open this app, and leave the phone alone while the test runs. Android has to believe the phone is idle to apply the restrictions we\'re testing — touching the phone makes the result unreliable. The three checks are deliberately spaced out rather than all firing at the end: the strongest one wakes the phone and would rescue the weaker ones, making the result look better than it is. That\'s why the notifications arrive one at a time.';

  @override
  String get testStartButton => 'Start test';

  @override
  String get testNeedPermissions =>
      'Some permissions needed for the test are missing.';

  @override
  String get testGoToDashboard => 'Go to Dashboard';

  @override
  String get testRunningTitle => 'Test running';

  @override
  String testTimeRemaining(String time) {
    return 'Time remaining: $time';
  }

  @override
  String get testCancelButton => 'Cancel test';

  @override
  String get testResultsTitle => 'Test results';

  @override
  String get testDirtyResultBanner => 'This is NOT a clean reading.';

  @override
  String get testScreenUnlocked => 'The screen was unlocked during the test.';

  @override
  String get testScreenUnlockedUnknown =>
      'Can\'t verify whether the screen was unlocked during the test (missing usage-access permission) — the result is probably valid, but we can\'t confirm it.';

  @override
  String get testRebooted => 'The phone rebooted during the test.';

  @override
  String get testNewTest => 'New test';

  @override
  String get testRunInProgress =>
      'A test is already running — showing its progress.';

  @override
  String get testNoResultsYet => 'Results aren\'t ready yet.';

  @override
  String get laneAlarmClockTitle => 'Alarm (strongest)';

  @override
  String get laneAlarmClockDesc =>
      'The strongest kind of alarm Android offers — this is how alarm clocks work.';

  @override
  String get laneExactIdleTitle => 'Exact reminder';

  @override
  String get laneExactIdleDesc => 'This is what reminder apps use.';

  @override
  String get laneWorkManagerTitle => 'Background sync';

  @override
  String get laneWorkManagerDesc =>
      'This is what chat and sync apps use — the first thing manufacturers kill.';

  @override
  String get outcomePending => 'Waiting…';

  @override
  String get outcomeFiredOnTime => 'Arrived on time';

  @override
  String get outcomeFiredLate => 'Late';

  @override
  String get outcomeNeverFired => 'Never arrived';

  @override
  String get outcomeCancelled => 'Cancelled';

  @override
  String outcomeDelay(String delay) {
    return 'Delay: $delay';
  }

  @override
  String get fixGuideTitle => 'Fix guide';

  @override
  String fixGuideAggressiveness(int rank) {
    return 'Aggressiveness level: $rank/5';
  }

  @override
  String fixGuideUnverified(String brand) {
    return 'The steps for $brand haven\'t been physically verified on a real device of that brand yet — menus may differ.';
  }

  @override
  String get fixGuideConfirmCheckbox => 'I confirm I did this';

  @override
  String get fixGuideOpenFailed =>
      'Couldn\'t open settings automatically. Go manually: Settings → Battery / Apps.';

  @override
  String get fixGuideOpenSucceeded =>
      'Settings opened — check whether you changed the required option.';

  @override
  String get fixGuideNoSteps =>
      'There are no steps defined for this brand yet.';

  @override
  String get fixGuideLoadError =>
      'Couldn\'t load the fix guide for this device\'s brand.';

  @override
  String get historyTitle => 'Test history';

  @override
  String get historyEmpty =>
      'No tests yet. Run your first one from the Test tab.';

  @override
  String get historyDirtyTag => 'Unreliable';

  @override
  String get historyUnknownTag => 'Partly unknown';

  @override
  String historyWindowLabel(int minutes) {
    return 'Window: $minutes min';
  }

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutWhatItKnows => 'What the app actually knows';

  @override
  String get aboutWhatItKnowsBody =>
      'The app only reads what Android publicly allows it to read — the state of battery restrictions, permissions, and the results of its own delivery test.';

  @override
  String get aboutWhatItCannotKnow => 'What the app can\'t know';

  @override
  String get aboutWhatItCannotKnowBody =>
      'Android has no public way to read whether a manufacturer\'s \'autostart\' switches are on. That\'s why the app asks you to confirm by hand instead of claiming to know something it never checked.';

  @override
  String get aboutNoDataCollection =>
      'The app doesn\'t collect, send, or store any of your data outside your phone.';

  @override
  String get aboutNoBatteryClaim =>
      'The app doesn\'t claim it will extend your battery life — its only purpose is to show the truth about why notifications aren\'t arriving.';

  @override
  String get aboutTipTitle => 'Tip';

  @override
  String get aboutTipBody =>
      'Someday there will be an optional tip here to support development. Purchases aren\'t available in the app yet.';

  @override
  String get aboutTipComingSoon => 'Coming soon';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }
}
