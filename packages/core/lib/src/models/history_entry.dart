/// Run log kind parsed by [RunHistoryService].
enum RunHistoryKind { scan, cleanup }

/// Parsed summary entry for one scan/cleanup run log file.
class RunHistoryEntry {
  /// Creates a run history entry.
  const RunHistoryEntry({
    required this.filePath,
    required this.fileName,
    required this.kind,
    required this.timestamp,
    required this.profile,
    this.totalBytes,
    this.reclaimedBytes,
    this.projectCount,
    this.itemCount,
    this.successCount,
    this.failureCount,
    this.skippedCount,
    this.cancelled = false,
    this.warningCount = 0,
    this.deltaBytesFromPreviousScan,
  });

  /// Absolute path to the original log file.
  final String filePath;

  /// File name of the original log file.
  final String fileName;

  /// Log kind inferred from file prefix.
  final RunHistoryKind kind;

  /// Run timestamp (`finishedAt` preferred).
  final DateTime timestamp;

  /// Profile string recorded in the log.
  final String profile;

  /// Total bytes for scan logs.
  final int? totalBytes;

  /// Reclaimed bytes for cleanup logs.
  final int? reclaimedBytes;

  /// Project count for scan logs.
  final int? projectCount;

  /// Item count for cleanup logs.
  final int? itemCount;

  /// Success count for cleanup logs.
  final int? successCount;

  /// Failure count for cleanup logs.
  final int? failureCount;

  /// Skipped count for cleanup logs.
  final int? skippedCount;

  /// Whether the run ended due to cancellation.
  final bool cancelled;

  /// Warning count associated with the run.
  final int warningCount;

  /// Delta from previous scan total (scan entries only).
  final int? deltaBytesFromPreviousScan;

  /// Returns a copy with updated scan delta.
  RunHistoryEntry copyWith({int? deltaBytesFromPreviousScan}) {
    return RunHistoryEntry(
      filePath: filePath,
      fileName: fileName,
      kind: kind,
      timestamp: timestamp,
      profile: profile,
      totalBytes: totalBytes,
      reclaimedBytes: reclaimedBytes,
      projectCount: projectCount,
      itemCount: itemCount,
      successCount: successCount,
      failureCount: failureCount,
      skippedCount: skippedCount,
      cancelled: cancelled,
      warningCount: warningCount,
      deltaBytesFromPreviousScan: deltaBytesFromPreviousScan,
    );
  }

  /// Serializes entry payload as JSON.
  Map<String, Object?> toJson() => {
    'filePath': filePath,
    'fileName': fileName,
    'kind': kind.name,
    'timestamp': timestamp.toIso8601String(),
    'profile': profile,
    'totalBytes': totalBytes,
    'reclaimedBytes': reclaimedBytes,
    'projectCount': projectCount,
    'itemCount': itemCount,
    'successCount': successCount,
    'failureCount': failureCount,
    'skippedCount': skippedCount,
    'cancelled': cancelled,
    'warningCount': warningCount,
    'deltaBytesFromPreviousScan': deltaBytesFromPreviousScan,
  };
}
