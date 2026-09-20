/// Status of a single restriction the app inspects.
///
/// [unavailable] is load-bearing: when a data source is blocked or missing on this
/// API level, the app says so. It never guesses a value and never renders a green
/// check it did not actually read.
enum DiagnosticStatus { ok, warning, problem, unavailable }

class DiagnosticItem {
  final String id;
  final DiagnosticStatus status;

  /// Raw reading behind the status, e.g. "ACTIVE" for the standby bucket.
  /// Null when [status] is [DiagnosticStatus.unavailable].
  final String? rawValue;

  /// Why the reading could not be taken — shown to the user verbatim.
  final String? unavailableReason;

  /// Whether this item can be acted on by opening a settings screen.
  final bool hasSettingsShortcut;

  const DiagnosticItem({
    required this.id,
    required this.status,
    this.rawValue,
    this.unavailableReason,
    this.hasSettingsShortcut = false,
  });

  factory DiagnosticItem.fromMap(Map<String, Object?> map) {
    final statusName = map['status'] as String? ?? 'unavailable';
    return DiagnosticItem(
      id: map['id'] as String,
      status: DiagnosticStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => DiagnosticStatus.unavailable,
      ),
      rawValue: map['rawValue'] as String?,
      unavailableReason: map['unavailableReason'] as String?,
      hasSettingsShortcut: map['hasSettingsShortcut'] as bool? ?? false,
    );
  }
}

class DeviceInfo {
  final String manufacturer;
  final String brand;
  final String model;
  final String androidRelease;
  final int sdkInt;

  const DeviceInfo({
    required this.manufacturer,
    required this.brand,
    required this.model,
    required this.androidRelease,
    required this.sdkInt,
  });

  factory DeviceInfo.fromMap(Map<String, Object?> map) => DeviceInfo(
        manufacturer: map['manufacturer'] as String? ?? 'unknown',
        brand: map['brand'] as String? ?? 'unknown',
        model: map['model'] as String? ?? 'unknown',
        androidRelease: map['androidRelease'] as String? ?? 'unknown',
        sdkInt: map['sdkInt'] as int? ?? 0,
      );
}
