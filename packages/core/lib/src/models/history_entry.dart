enum RunHistoryKind { scan, cleanup }

class RunHistoryEntry {
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

  final String filePath;
  final String fileName;
  final RunHistoryKind kind;
  final DateTime timestamp;
  final String profile;
  final int? totalBytes;
  final int? reclaimedBytes;
  final int? projectCount;
  final int? itemCount;
  final int? successCount;
  final int? failureCount;
  final int? skippedCount;
  final bool cancelled;
  final int warningCount;
  final int? deltaBytesFromPreviousScan;

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
