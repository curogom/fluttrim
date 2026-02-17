import 'cache_category.dart';
import 'attribution_status.dart';
import 'profile.dart';
import 'risk.dart';

/// Final scan output containing project/global/xcode target sizes.
class ScanResult {
  /// Creates a scan result.
  const ScanResult({
    required this.startedAt,
    required this.finishedAt,
    required this.profile,
    required this.cancelled,
    required this.projects,
    this.xcodeTargets = const [],
    this.globalTargets = const [],
  });

  /// UTC timestamp when scan started.
  final DateTime startedAt;

  /// UTC timestamp when scan finished.
  final DateTime finishedAt;

  /// Profile used by this scan.
  final Profile profile;

  /// Whether the scan was cancelled before normal completion.
  final bool cancelled;

  /// Project-level scan results.
  final List<ProjectScanResult> projects;

  /// Xcode cache targets (macOS only when enabled).
  final List<TargetScanResult> xcodeTargets;

  /// Global cache targets when enabled.
  final List<TargetScanResult> globalTargets;

  /// Total bytes across project, xcode, and global targets.
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

  /// Category totals aggregated from all targets.
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

  /// Serializes result payload as JSON.
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

/// Per-project scan result.
class ProjectScanResult {
  /// Creates a project scan result.
  const ProjectScanResult({
    required this.name,
    required this.rootPath,
    required this.targets,
  });

  /// Project name from `pubspec.yaml` (fallback: directory name).
  final String name;

  /// Absolute project root path.
  final String rootPath;

  /// Target scan results for this project.
  final List<TargetScanResult> targets;

  /// Sum of target sizes for this project.
  int get totalBytes => targets.fold(0, (prev, t) => prev + t.sizeBytes);

  /// Serializes result payload as JSON.
  Map<String, Object?> toJson() => {
    'name': name,
    'rootPath': rootPath,
    'totalBytes': totalBytes,
    'targets': targets.map((e) => e.toJson()).toList(),
  };
}

/// Scan result for one concrete cleanup target path.
class TargetScanResult {
  /// Creates a target scan result.
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

  /// Target id from the static target registry.
  final String targetId;

  /// Category copied from target definition.
  final CacheCategory category;

  /// Risk level shown in UI/CLI.
  final Risk risk;

  /// Absolute target path.
  final String path;

  /// Whether path existed at scan time.
  final bool exists;

  /// Estimated bytes reclaimable for the target.
  final int sizeBytes;

  /// Attribution status for potentially shared caches.
  final AttributionStatus attributionStatus;

  /// Attributed project root path, when available.
  final String? attributedProjectRootPath;

  /// Attribution confidence in `0.0..1.0`, when available.
  final double? attributionConfidence;

  /// Evidence path used during attribution analysis.
  final String? attributionEvidencePath;

  /// Optional non-fatal scan error for this target.
  final String? error;

  /// Returns `true` when attribution is unknown.
  bool get hasUnknownAttribution =>
      attributionStatus == AttributionStatus.unknown;

  /// Serializes result payload as JSON.
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
