import 'cache_category.dart';
import 'attribution_status.dart';
import 'delete_mode.dart';
import 'profile.dart';
import 'risk.dart';

class CleanupPlan {
  const CleanupPlan({
    required this.createdAt,
    required this.profile,
    required this.deleteMode,
    required this.items,
    this.warnings = const [],
  });

  final DateTime createdAt;
  final Profile profile;
  final DeleteMode deleteMode;
  final List<CleanupPlanItem> items;
  final List<String> warnings;

  int get totalBytes => items.fold(0, (prev, item) => prev + item.sizeBytes);

  Map<String, Object?> toJson() => {
    'createdAt': createdAt.toIso8601String(),
    'profile': profile.toJsonValue(),
    'deleteMode': deleteMode.toJsonValue(),
    'warnings': warnings,
    'items': items.map((e) => e.toJson()).toList(),
    'totalBytes': totalBytes,
  };
}

class CleanupPlanItem {
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

  final String targetId;
  final CacheCategory category;
  final Risk risk;
  final String path;
  final int sizeBytes;
  final AttributionStatus attributionStatus;
  final String? attributedProjectRootPath;
  final double? attributionConfidence;
  final String? attributionEvidencePath;
  final String? projectRootPath;

  bool get hasUnknownAttribution =>
      attributionStatus == AttributionStatus.unknown;

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
