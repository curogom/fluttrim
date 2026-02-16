import 'delete_mode.dart';
import 'profile.dart';

enum CleanupItemStatus { success, failed, skipped }

class CleanupResult {
  const CleanupResult({
    required this.startedAt,
    required this.finishedAt,
    required this.profile,
    required this.deleteMode,
    required this.allowUnknown,
    required this.items,
  });

  final DateTime startedAt;
  final DateTime finishedAt;
  final Profile profile;
  final DeleteMode deleteMode;
  final bool allowUnknown;
  final List<CleanupItemResult> items;

  int get reclaimedBytes =>
      items.fold(0, (prev, item) => prev + item.reclaimedBytes);

  int get successCount =>
      items.where((item) => item.status == CleanupItemStatus.success).length;

  int get failureCount =>
      items.where((item) => item.status == CleanupItemStatus.failed).length;

  int get skippedCount =>
      items.where((item) => item.status == CleanupItemStatus.skipped).length;

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

class CleanupItemResult {
  const CleanupItemResult({
    required this.targetId,
    required this.path,
    required this.status,
    required this.reclaimedBytes,
    this.error,
  });

  final String targetId;
  final String path;
  final CleanupItemStatus status;
  final int reclaimedBytes;
  final String? error;

  Map<String, Object?> toJson() => {
    'targetId': targetId,
    'path': path,
    'status': status.name,
    'reclaimedBytes': reclaimedBytes,
    'error': error,
  };
}
