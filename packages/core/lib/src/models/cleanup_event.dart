import 'cleanup_result.dart';

/// Progress phase for a cleanup execution stream.
enum CleanupPhase { validating, deleting, done }

/// Streaming event emitted by [CleanupExecutor.execute].
class CleanupEvent {
  /// Internal constructor used by named factories.
  const CleanupEvent._({
    required this.phase,
    this.message,
    this.currentPath,
    this.progressDone,
    this.progressTotal,
    this.result,
  });

  /// Emits a validation-phase event.
  factory CleanupEvent.validating({
    String? message,
    String? currentPath,
    int? progressDone,
    int? progressTotal,
  }) {
    return CleanupEvent._(
      phase: CleanupPhase.validating,
      message: message,
      currentPath: currentPath,
      progressDone: progressDone,
      progressTotal: progressTotal,
    );
  }

  /// Emits a delete-phase event.
  factory CleanupEvent.deleting({
    String? message,
    String? currentPath,
    int? progressDone,
    int? progressTotal,
  }) {
    return CleanupEvent._(
      phase: CleanupPhase.deleting,
      message: message,
      currentPath: currentPath,
      progressDone: progressDone,
      progressTotal: progressTotal,
    );
  }

  /// Emits a completion event with final [result].
  factory CleanupEvent.done(CleanupResult result) {
    return CleanupEvent._(phase: CleanupPhase.done, result: result);
  }

  /// Current execution phase.
  final CleanupPhase phase;

  /// Optional human-readable progress message.
  final String? message;

  /// Path currently being validated or deleted.
  final String? currentPath;

  /// 1-based completed item count when progress is known.
  final int? progressDone;

  /// Total item count when progress is known.
  final int? progressTotal;

  /// Final cleanup result when [phase] is [CleanupPhase.done].
  final CleanupResult? result;

  /// Returns `true` when this event carries a final result.
  bool get isDone => phase == CleanupPhase.done && result != null;

  /// Serializes event payload as JSON.
  Map<String, Object?> toJson() => {
    'phase': phase.name,
    'message': message,
    'currentPath': currentPath,
    'progressDone': progressDone,
    'progressTotal': progressTotal,
    'result': result?.toJson(),
  };
}
