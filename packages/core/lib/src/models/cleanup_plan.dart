import 'cache_category.dart';
import 'attribution_status.dart';
import 'delete_mode.dart';
import 'profile.dart';
import 'risk.dart';

/// Immutable cleanup plan built from a [ScanResult].
class CleanupPlan {
  /// Creates a cleanup plan.
  const CleanupPlan({
    required this.createdAt,
    required this.profile,
    required this.deleteMode,
    required this.items,
    this.warnings = const [],
  });

  /// UTC timestamp when the plan was created.
  final DateTime createdAt;

  /// Profile that produced this plan.
  final Profile profile;

  /// Delete mode selected by caller.
  final DeleteMode deleteMode;

  /// Concrete cleanup items to execute.
  final List<CleanupPlanItem> items;

  /// Non-fatal warnings gathered while building the plan.
  final List<String> warnings;

  /// Sum of [CleanupPlanItem.sizeBytes].
  int get totalBytes => items.fold(0, (prev, item) => prev + item.sizeBytes);

  /// Serializes plan payload as JSON.
  Map<String, Object?> toJson() => {
    'createdAt': createdAt.toIso8601String(),
    'profile': profile.toJsonValue(),
    'deleteMode': deleteMode.toJsonValue(),
    'warnings': warnings,
    'items': items.map((e) => e.toJson()).toList(),
    'totalBytes': totalBytes,
  };
}

/// One validated cleanup target in a [CleanupPlan].
class CleanupPlanItem {
  /// Creates a cleanup plan item.
  const CleanupPlanItem({
    required this.targetId,
    required this.category,
    required this.risk,
    required this.path,
    required this.sizeBytes,
    this.attributionStatus = AttributionStatus.none,
    this.attributedProjectRootPath,
    this.attributionConfidence,
    this.attributionEvidencePath,
    this.projectRootPath,
  });

  /// Target id from the static target registry.
  final String targetId;

  /// Category copied from scan target definition.
  final CacheCategory category;

  /// Risk level shown to users.
  final Risk risk;

  /// Absolute filesystem path to clean.
  final String path;

  /// Estimated reclaimable bytes for this item.
  final int sizeBytes;

  /// Attribution status for potentially shared caches.
  final AttributionStatus attributionStatus;

  /// Attributed Flutter project root path, when available.
  final String? attributedProjectRootPath;

  /// Attribution confidence in `0.0..1.0`, when available.
  final double? attributionConfidence;

  /// Evidence path used during attribution analysis.
  final String? attributionEvidencePath;

  /// Project root for project-scoped targets.
  final String? projectRootPath;

  /// Returns `true` when attribution is unknown.
  bool get hasUnknownAttribution =>
      attributionStatus == AttributionStatus.unknown;

  /// Serializes item payload as JSON.
  Map<String, Object?> toJson() => {
    'targetId': targetId,
    'category': category.toJsonValue(),
    'risk': risk.toJsonValue(),
    'path': path,
    'sizeBytes': sizeBytes,
    'attributionStatus': attributionStatus.toJsonValue(),
    'attributedProjectRootPath': attributedProjectRootPath,
    'attributionConfidence': attributionConfidence,
    'attributionEvidencePath': attributionEvidencePath,
    'projectRootPath': projectRootPath,
  };
}
