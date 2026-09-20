import 'dart:async';

import '../../core/models/test_run.dart';
import '../../core/services/test_engine_service.dart';

/// In-memory stand-in for the real native test engine, which is being built
/// separately and doesn't exist yet. Lets the Test/History screens run and be
/// verified without a device. Never wired into a release build.
///
/// The simulated outcomes below are fabricated on purpose for preview only —
/// that does not relax the app's own rule against inventing readings: a real
/// [TestEngineService] must only ever report what a native lane actually
/// observed.
class DevTestEngineService extends TestEngineService {
  TestRun? _current;
  final List<TestRun> _history = [];
  RebootProbe? _rebootProbe;

  @override
  Future<bool> canRun() async => true;

  @override
  Future<TestRun> start(Duration window) async {
    final now = DateTime.now();
    final scheduledFor = now.add(window);
    final run = TestRun(
      id: now.microsecondsSinceEpoch.toString(),
      startedAt: now,
      window: window,
      lanes: [
        LaneResult(
          lane: LaneId.alarmClock,
          outcome: LaneOutcome.pending,
          scheduledFor: scheduledFor,
        ),
        LaneResult(
          lane: LaneId.exactIdle,
          outcome: LaneOutcome.pending,
          scheduledFor: scheduledFor,
        ),
        LaneResult(
          lane: LaneId.workManager,
          outcome: LaneOutcome.pending,
          scheduledFor: scheduledFor,
        ),
      ],
    );
    _current = run;
    return run;
  }

  @override
  Future<TestRun?> currentRun() async => _current;

  @override
  Future<TestRun?> collectResults() async {
    final run = _current;
    if (run == null) return null;

    final elapsed = DateTime.now().difference(run.startedAt);
    if (elapsed < run.window) return run;

    final scheduledFor = run.startedAt.add(run.window);
    final resolved = TestRun(
      id: run.id,
      startedAt: run.startedAt,
      window: run.window,
      screenUnlockedDuringTest: run.screenUnlockedDuringTest,
      rebootedDuringTest: run.rebootedDuringTest,
      lanes: [
        LaneResult(
          lane: LaneId.alarmClock,
          outcome: LaneOutcome.firedOnTime,
          scheduledFor: scheduledFor,
          firedAt: scheduledFor,
        ),
        LaneResult(
          lane: LaneId.exactIdle,
          outcome: LaneOutcome.firedLate,
          scheduledFor: scheduledFor,
          firedAt: scheduledFor.add(const Duration(minutes: 4)),
        ),
        LaneResult(
          lane: LaneId.workManager,
          outcome: LaneOutcome.neverFired,
          scheduledFor: scheduledFor,
        ),
      ],
    );
    _current = null;
    _history.insert(0, resolved);
    return resolved;
  }

  @override
  Future<void> cancel() async {
    final run = _current;
    if (run == null) return;
    _current = null;
    _history.insert(
      0,
      TestRun(
        id: run.id,
        startedAt: run.startedAt,
        window: run.window,
        lanes: run.lanes
            .map((l) => LaneResult(
                  lane: l.lane,
                  outcome: LaneOutcome.cancelled,
                  scheduledFor: l.scheduledFor,
                ))
            .toList(),
      ),
    );
  }

  @override
  Future<void> armRebootProbe() async {
    _rebootProbe = RebootProbe(armedAt: DateTime.now());
  }

  @override
  Future<RebootProbe?> rebootProbe() async => _rebootProbe;

  @override
  Future<List<TestRun>> history() async => List.unmodifiable(_history);
}
