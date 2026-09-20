import 'important_app_ref.dart';

/// Real battery-optimization-exemption reading for another installed app.
/// [unavailable] is load-bearing here just like [DiagnosticStatus.unavailable]:
/// a failed/unknown read must never be coerced into [notExempt].
enum BulkFixStatus { exempt, notExempt, unavailable }

/// Runtime view-model row for the bulk-fix app list, built by joining
/// installed-app-scan results, curated [ImportantAppRef] matches, and
/// battery-exemption reads. The join happens in the UI layer; this is just
/// the shape it produces.
class BulkFixAppEntry {
  final String package;

  /// Curated Croatian name if matched, else the real PackageManager label.
  final String displayLabel;

  /// [AppCategory.other] if not in the curated list.
  final AppCategory category;
  final bool isCurated;
  final BulkFixStatus status;

  const BulkFixAppEntry({
    required this.package,
    required this.displayLabel,
    required this.category,
    required this.isCurated,
    required this.status,
  });

  BulkFixAppEntry copyWith({BulkFixStatus? status}) => BulkFixAppEntry(
        package: package,
        displayLabel: displayLabel,
        category: category,
        isCurated: isCurated,
        status: status ?? this.status,
      );
}
