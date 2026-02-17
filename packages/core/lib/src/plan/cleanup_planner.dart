import 'package:path/path.dart' as p;

import '../models/cache_category.dart';
import '../models/cleanup_plan.dart';
import '../models/delete_mode.dart';
import '../models/scan_result.dart';
import '../targets/target_registry.dart';

/// Converts [ScanResult] into a validated, executable [CleanupPlan].
class CleanupPlanner {
  /// Creates a cleanup planner.
  const CleanupPlanner();

  /// Builds a cleanup plan from [scan].
  ///
  /// Throws [InvalidPlanException] when target ids are unknown or when a
  /// project target escapes its project root containment rules.
  CleanupPlan createPlan({
    required ScanResult scan,
    DeleteMode deleteMode = DeleteMode.trash,
    Set<String>? targetIds,
    bool allowUnknown = false,
  }) {
    final items = <CleanupPlanItem>[];
    final warnings = <String>[];
    var skippedUnknownAttribution = 0;

    for (final project in scan.projects) {
      for (final target in project.targets) {
        if (targetIds != null && !targetIds.contains(target.targetId)) {
          continue;
        }
        final def = TargetRegistry.byId(target.targetId);
        if (def == null) {
          throw InvalidPlanException('Unknown targetId: ${target.targetId}');
        }
        if (!def.isIncludedIn(scan.profile)) {
          continue;
        }
        if (!target.exists || target.sizeBytes <= 0) {
          continue;
        }
        if (target.hasUnknownAttribution && !allowUnknown) {
          skippedUnknownAttribution++;
          continue;
        }
        if (target.category == CacheCategory.project) {
          final root = project.rootPath;
          if (!(p.isWithin(root, target.path) || p.equals(root, target.path))) {
            throw InvalidPlanException(
              'Target path escapes project root. root=$root path=${target.path}',
            );
          }
        }
        items.add(
          CleanupPlanItem(
            targetId: target.targetId,
            category: target.category,
            risk: target.risk,
            path: target.path,
            sizeBytes: target.sizeBytes,
            attributionStatus: target.attributionStatus,
            attributedProjectRootPath: target.attributedProjectRootPath,
            attributionConfidence: target.attributionConfidence,
            attributionEvidencePath: target.attributionEvidencePath,
            projectRootPath: target.category == CacheCategory.project
                ? project.rootPath
                : null,
          ),
        );
      }
    }

    for (final target in scan.xcodeTargets) {
      if (targetIds != null && !targetIds.contains(target.targetId)) {
        continue;
      }
      final def = TargetRegistry.byId(target.targetId);
      if (def == null) {
        throw InvalidPlanException('Unknown targetId: ${target.targetId}');
      }
      if (!def.isIncludedIn(scan.profile)) {
        continue;
      }
      if (!target.exists || target.sizeBytes <= 0) {
        continue;
      }
      if (target.hasUnknownAttribution && !allowUnknown) {
        skippedUnknownAttribution++;
        continue;
      }
      items.add(
        CleanupPlanItem(
          targetId: target.targetId,
          category: target.category,
          risk: target.risk,
          path: target.path,
          sizeBytes: target.sizeBytes,
          attributionStatus: target.attributionStatus,
          attributedProjectRootPath: target.attributedProjectRootPath,
          attributionConfidence: target.attributionConfidence,
          attributionEvidencePath: target.attributionEvidencePath,
          projectRootPath: null,
        ),
      );
    }

    for (final target in scan.globalTargets) {
      if (targetIds != null && !targetIds.contains(target.targetId)) {
        continue;
      }
      final def = TargetRegistry.byId(target.targetId);
      if (def == null) {
        throw InvalidPlanException('Unknown targetId: ${target.targetId}');
      }
      if (!def.isIncludedIn(scan.profile)) {
        continue;
      }
      if (!target.exists || target.sizeBytes <= 0) {
        continue;
      }
      if (target.hasUnknownAttribution && !allowUnknown) {
        skippedUnknownAttribution++;
        continue;
      }
      items.add(
        CleanupPlanItem(
          targetId: target.targetId,
          category: target.category,
          risk: target.risk,
          path: target.path,
          sizeBytes: target.sizeBytes,
          attributionStatus: target.attributionStatus,
          attributedProjectRootPath: target.attributedProjectRootPath,
          attributionConfidence: target.attributionConfidence,
          attributionEvidencePath: target.attributionEvidencePath,
          projectRootPath: null,
        ),
      );
    }

    if (skippedUnknownAttribution > 0) {
      warnings.add(
        'Skipped $skippedUnknownAttribution unknown-attribution target(s). '
        'Enable allowUnknown to include them.',
      );
    }

    return CleanupPlan(
      createdAt: DateTime.now().toUtc(),
      profile: scan.profile,
      deleteMode: deleteMode,
      items: items,
      warnings: warnings,
    );
  }
}

/// Error thrown when a cleanup plan cannot be validated safely.
class InvalidPlanException implements Exception {
  /// Creates an invalid-plan exception with [message].
  InvalidPlanException(this.message);

  /// Error reason.
  final String message;

  @override
  String toString() => 'InvalidPlanException: $message';
}
