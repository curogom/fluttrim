import 'delete_mode.dart';
import 'profile.dart';

/// Per-item outcome kind for cleanup execution.
enum CleanupItemStatus { success, failed, skipped }

/// Final result produced by [CleanupExecutor.execute].
class CleanupResult {
  /// Creates a cleanup result.
  const CleanupResult({
    required this.startedAt,
    required this.finishedAt,
    required this.profile,
    required this.deleteMode,
    required this.allowUnknown,
    required this.items,
  });

  /// UTC timestamp when execution started.
  final DateTime startedAt;

  /// UTC timestamp when execution finished.
  final DateTime finishedAt;

  /// Profile used during scan/plan.
  final Profile profile;

  /// Effective delete mode for this run.
  final DeleteMode deleteMode;

  /// Whether unknown attribution was allowed.
  final bool allowUnknown;

  /// Per-target execution results.
  final List<CleanupItemResult> items;

  /// Total reclaimed bytes across successful items.
  int get reclaimedBytes =>
      items.fold(0, (prev, item) => prev + item.reclaimedBytes);

  /// Number of successful items.
  int get successCount =>
      items.where((item) => item.status == CleanupItemStatus.success).length;

  /// Number of failed items.
  int get failureCount =>
      items.where((item) => item.status == CleanupItemStatus.failed).length;

  /// Number of skipped items.
  int get skippedCount =>
      items.where((item) => item.status == CleanupItemStatus.skipped).length;

  /// Serializes result payload as JSON.
  Map<String, Object?> toJson() => {
    'startedAt': startedAt.toIso8601String(),
    'finishedAt': finishedAt.toIso8601String(),
    'profile': profile.toJsonValue(),
    'deleteMode': deleteMode.toJsonValue(),
    'allowUnknown': allowUnknown,
    'items': items.map((e) => e.toJson()).toList(),
    'reclaimedBytes': reclaimedBytes,
    'successCount': successCount,
    'failureCount': failureCount,
    'skippedCount': skippedCount,
  };
}

/// Result for a single cleanup plan item.
class CleanupItemResult {
  /// Creates a per-item cleanup result.
  const CleanupItemResult({
    required this.targetId,
    required this.path,
    required this.status,
    required this.reclaimedBytes,
    this.error,
  });

  /// Target id from the plan.
  final String targetId;

  /// Absolute path that was attempted.
  final String path;

  /// Final item status.
  final CleanupItemStatus status;

  /// Reclaimed bytes for this item.
  final int reclaimedBytes;

  /// Optional error text for failed/skipped items.
  final String? error;

  /// Serializes item payload as JSON.
  Map<String, Object?> toJson() => {
    'targetId': targetId,
    'path': path,
    'status': status.name,
    'reclaimedBytes': reclaimedBytes,
    'error': error,
  };
}
