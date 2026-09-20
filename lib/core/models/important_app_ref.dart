/// Curated category for an important app tracked by the bulk-fix feature.
enum AppCategory { messaging, banking, calendar, other }

/// A curated third-party app the bulk-fix screen specifically calls out
/// (e.g. WhatsApp, a bank app) with a Croatian display name, sourced from
/// `assets/important_apps.json`.
class ImportantAppRef {
  final String package;
  final String nameHr;
  final AppCategory category;

  const ImportantAppRef({
    required this.package,
    required this.nameHr,
    required this.category,
  });

  factory ImportantAppRef.fromJson(Map<String, Object?> json) {
    final categoryName = json['category'] as String?;
    final category = AppCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => AppCategory.other,
    );
    return ImportantAppRef(
      package: json['package'] as String? ?? '',
      nameHr: json['nameHr'] as String? ?? '',
      category: category,
    );
  }
}
