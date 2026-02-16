import 'cache_category.dart';
import 'attribution_status.dart';
import 'profile.dart';
import 'risk.dart';

class ScanResult {
  const ScanResult({
    required this.startedAt,
    required this.finishedAt,
    required this.profile,
    required this.cancelled,
    required this.projects,
    this.xcodeTargets = const [],
    this.globalTargets = const [],
  });

  final DateTime startedAt;
  final DateTime finishedAt;
  final Profile profile;
  final bool cancelled;
  final List<ProjectScanResult> projects;
  final List<TargetScanResult> xcodeTargets;
  final List<TargetScanResult> globalTargets;

  int get totalBytes {
    final projectBytes = projects.fold(
      0,
      (prev, project) => prev + project.totalBytes,
    );
    final globalBytes = globalTargets.fold(
      0,
      (prev, target) => prev + target.sizeBytes,
    );
    final xcodeBytes = xcodeTargets.fold(
      0,
      (prev, target) => prev + target.sizeBytes,
    );
    return projectBytes + xcodeBytes + globalBytes;
  }

  Map<CacheCategory, int> get totalsByCategory {
    final totals = <CacheCategory, int>{
      for (final c in CacheCategory.values) c: 0,
    };
    for (final project in projects) {
      for (final t in project.targets) {
        totals[t.category] = (totals[t.category] ?? 0) + t.sizeBytes;
      }
    }
    for (final target in globalTargets) {
      totals[target.category] =
          (totals[target.category] ?? 0) + target.sizeBytes;
    }
    for (final target in xcodeTargets) {
      totals[target.category] =
          (totals[target.category] ?? 0) + target.sizeBytes;
    }
    return totals;
  }

  Map<String, Object?> toJson() => {
    'startedAt': startedAt.toIso8601String(),
    'finishedAt': finishedAt.toIso8601String(),
    'profile': profile.toJsonValue(),
    'cancelled': cancelled,
    'projects': projects.map((e) => e.toJson()).toList(),
    'xcodeTargets': xcodeTargets.map((e) => e.toJson()).toList(),
    'globalTargets': globalTargets.map((e) => e.toJson()).toList(),
    'totalsByCategory': totalsByCategory.map(
      (k, v) => MapEntry(k.toJsonValue(), v),
    ),
    'totalBytes': totalBytes,
  };
}

class ProjectScanResult {
  const ProjectScanResult({
    required this.name,
    required this.rootPath,
    required this.targets,
  });

  final String name;
  final String rootPath;
  final List<TargetScanResult> targets;

  int get totalBytes => targets.fold(0, (prev, t) => prev + t.sizeBytes);

  Map<String, Object?> toJson() => {
    'name': name,
    'rootPath': rootPath,
    'totalBytes': totalBytes,
    'targets': targets.map((e) => e.toJson()).toList(),
  };
}

class TargetScanResult {
  const TargetScanResult({
    required this.targetId,
    required this.category,
    required this.risk,
    required this.path,
    required this.exists,
    required this.sizeBytes,
    this.attributionStatus = AttributionStatus.none,
    this.attributedProjectRootPath,
    this.attributionConfidence,
    this.attributionEvidencePath,
    this.error,
  });

  final String targetId;
  final CacheCategory category;
  final Risk risk;
  final String path;
  final bool exists;
  final int sizeBytes;
  final AttributionStatus attributionStatus;
  final String? attributedProjectRootPath;
  final double? attributionConfidence;
  final String? attributionEvidencePath;
  final String? error;

  bool get hasUnknownAttribution =>
      attributionStatus == AttributionStatus.unknown;

  Map<String, Object?> toJson() => {
    'targetId': targetId,
    'category': category.toJsonValue(),
    'risk': risk.toJsonValue(),
    'path': path,
    'exists': exists,
    'sizeBytes': sizeBytes,
    'attributionStatus': attributionStatus.toJsonValue(),
    'attributedProjectRootPath': attributedProjectRootPath,
    'attributionConfidence': attributionConfidence,
    'attributionEvidencePath': attributionEvidencePath,
    'error': error,
  };
}
