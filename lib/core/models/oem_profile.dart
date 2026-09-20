/// One candidate way to reach a settings screen. Candidates are tried in order:
/// OEM activities get renamed and removed between OS versions, so every step needs
/// a fallback chain ending in a screen that is guaranteed to exist.
class IntentCandidate {
  final String? action;
  final String? package;
  final String? component;

  /// Append `package:<our package name>` as the intent's data URI.
  final bool usesPackageData;

  const IntentCandidate({
    this.action,
    this.package,
    this.component,
    this.usesPackageData = false,
  });

  factory IntentCandidate.fromJson(Map<String, Object?> json) =>
      IntentCandidate(
        action: json['action'] as String?,
        package: json['package'] as String?,
        component: json['component'] as String?,
        usesPackageData: json['usesPackageData'] as bool? ?? false,
      );
}

class FixStep {
  final String id;
  final String titleHr;
  final String titleEn;
  final String bodyHr;
  final String bodyEn;
  final List<IntentCandidate> intents;

  /// True when the app cannot read the resulting state (all OEM autostart toggles),
  /// so the user has to confirm by hand instead of the app claiming to know.
  final bool requiresManualConfirm;

  const FixStep({
    required this.id,
    required this.titleHr,
    required this.titleEn,
    required this.bodyHr,
    required this.bodyEn,
    required this.intents,
    this.requiresManualConfirm = true,
  });

  factory FixStep.fromJson(Map<String, Object?> json) => FixStep(
        id: json['id'] as String,
        titleHr: json['titleHr'] as String,
        titleEn: json['titleEn'] as String,
        bodyHr: json['bodyHr'] as String,
        bodyEn: json['bodyEn'] as String,
        intents: (json['intents'] as List? ?? [])
            .cast<Map<String, Object?>>()
            .map(IntentCandidate.fromJson)
            .toList(),
        requiresManualConfirm: json['requiresManualConfirm'] as bool? ?? true,
      );
}

class OemProfile {
  final String id;
  final String displayName;

  /// Lowercased Build.MANUFACTURER / Build.BRAND values this profile matches.
  final List<String> manufacturerMatches;

  /// 1 = close to stock, 5 = kills everything.
  final int aggressivenessRank;

  final List<FixStep> steps;

  /// False when nobody has run this profile on a physical device of that brand —
  /// the UI says so rather than implying the steps are confirmed.
  final bool verified;

  const OemProfile({
    required this.id,
    required this.displayName,
    required this.manufacturerMatches,
    required this.aggressivenessRank,
    required this.steps,
    this.verified = false,
  });

  factory OemProfile.fromJson(Map<String, Object?> json) => OemProfile(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        manufacturerMatches: (json['manufacturerMatches'] as List? ?? [])
            .cast<String>(),
        aggressivenessRank: json['aggressivenessRank'] as int? ?? 3,
        steps: (json['steps'] as List? ?? [])
            .cast<Map<String, Object?>>()
            .map(FixStep.fromJson)
            .toList(),
        verified: json['verified'] as bool? ?? false,
      );
}
