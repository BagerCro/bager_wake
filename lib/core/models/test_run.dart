/// The three scheduling mechanisms the delivery test races against each other.
///
/// They are deliberately different strengths: comparing which ones survive is what
/// tells the user *what* their phone is throttling.
enum LaneId {
  /// AlarmManager.setAlarmClock() — strongest guarantee the platform offers.
  alarmClock,

  /// AlarmManager.setExactAndAllowWhileIdle() — what reminder apps typically use.
  exactIdle,

  /// WorkManager job — what sync/chat apps use; first thing OEMs kill.
  workManager,
}

enum LaneOutcome { pending, firedOnTime, firedLate, neverFired, cancelled }

class LaneResult {
  final LaneId lane;
  final LaneOutcome outcome;
  final DateTime scheduledFor;
  final DateTime? firedAt;

  const LaneResult({
    required this.lane,
    required this.outcome,
    required this.scheduledFor,
    this.firedAt,
  });

  Duration? get delay => firedAt?.difference(scheduledFor);

  Map<String, Object?> toJson() => {
        'lane': lane.name,
        'outcome': outcome.name,
        'scheduledFor': scheduledFor.millisecondsSinceEpoch,
        'firedAt': firedAt?.millisecondsSinceEpoch,
      };

  factory LaneResult.fromJson(Map<String, Object?> json) => LaneResult(
        lane: LaneId.values.byName(json['lane'] as String),
        outcome: LaneOutcome.values.byName(json['outcome'] as String),
        scheduledFor:
            DateTime.fromMillisecondsSinceEpoch(json['scheduledFor'] as int),
        firedAt: json['firedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json['firedAt'] as int),
      );
}

class TestRun {
  final String id;
  final DateTime startedAt;
  final Duration window;
  final List<LaneResult> lanes;

  /// Null means it could not be determined — reading it needs the Usage Access
  /// grant. Unknown is reported as unknown; it is never flattened into "no".
  final bool? screenUnlockedDuringTest;

  /// Detected from the elapsed-realtime clock, so it needs no permission and works
  /// even when the boot receiver was blocked from running.
  final bool rebootedDuringTest;

  const TestRun({
    required this.id,
    required this.startedAt,
    required this.window,
    required this.lanes,
    this.screenUnlockedDuringTest,
    this.rebootedDuringTest = false,
  });

  bool get isComplete =>
      lanes.every((l) => l.outcome != LaneOutcome.pending);

  Map<String, Object?> toJson() => {
        'id': id,
        'startedAt': startedAt.millisecondsSinceEpoch,
        'windowSeconds': window.inSeconds,
        'lanes': lanes.map((l) => l.toJson()).toList(),
        'screenUnlockedDuringTest': screenUnlockedDuringTest,
        'rebootedDuringTest': rebootedDuringTest,
      };

  factory TestRun.fromJson(Map<String, Object?> json) => TestRun(
        id: json['id'] as String,
        startedAt:
            DateTime.fromMillisecondsSinceEpoch(json['startedAt'] as int),
        window: Duration(seconds: json['windowSeconds'] as int),
        lanes: (json['lanes'] as List)
            .cast<Map<String, Object?>>()
            .map(LaneResult.fromJson)
            .toList(),
        screenUnlockedDuringTest: json['screenUnlockedDuringTest'] as bool?,
        rebootedDuringTest: json['rebootedDuringTest'] as bool? ?? false,
      );
}

/// Result of the reboot probe — the only way to infer OEM autostart state, since
/// no public API exposes it.
class RebootProbe {
  final DateTime armedAt;
  final DateTime? bootReceivedAt;

  const RebootProbe({required this.armedAt, this.bootReceivedAt});

  Map<String, Object?> toJson() => {
        'armedAt': armedAt.millisecondsSinceEpoch,
        'bootReceivedAt': bootReceivedAt?.millisecondsSinceEpoch,
      };

  factory RebootProbe.fromJson(Map<String, Object?> json) => RebootProbe(
        armedAt: DateTime.fromMillisecondsSinceEpoch(json['armedAt'] as int),
        bootReceivedAt: json['bootReceivedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                json['bootReceivedAt'] as int),
      );
}
