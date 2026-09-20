import '../models/test_run.dart';

/// Public surface of the delivery test. The UI is built against exactly these
/// signatures; the native scheduling and recording behind them is implemented
/// separately (see the test-engine work item).
///
/// Contract the implementation must hold to:
/// - Fire times are recorded natively, because the Flutter engine is often dead
///   by the time a lane fires — that is the very condition under test.
/// - A lane that never fired is reported as [LaneOutcome.neverFired]. It is never
///   silently dropped or backfilled with an estimate.
/// - [collectResults] is safe to call at any point; lanes still in flight come
///   back as [LaneOutcome.pending].
abstract class TestEngineService {
  /// Whether the permissions each lane needs are in place. When false, the UI
  /// sends the user to the dashboard to grant them first.
  Future<bool> canRun();

  /// Schedules all three lanes [window] into the future and persists the run.
  Future<TestRun> start(Duration window);

  /// The run currently in flight, or null.
  Future<TestRun?> currentRun();

  /// Reads whatever the native side has recorded so far for the current run.
  Future<TestRun?> collectResults();

  Future<void> cancel();

  /// Arms the reboot probe: the user restarts the phone, and whether the boot
  /// receiver ever ran tells us what no public API exposes — the OEM autostart
  /// state.
  Future<void> armRebootProbe();

  Future<RebootProbe?> rebootProbe();

  /// Completed runs, newest first.
  Future<List<TestRun>> history();
}
