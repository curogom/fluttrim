import 'cleanup_result.dart';

enum CleanupPhase { validating, deleting, done }

class CleanupEvent {
  const CleanupEvent._({
    required this.phase,
    this.message,
    this.currentPath,
    this.progressDone,
    this.progressTotal,
    this.result,
  });

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

  factory CleanupEvent.done(CleanupResult result) {
    return CleanupEvent._(phase: CleanupPhase.done, result: result);
  }

  final CleanupPhase phase;
  final String? message;
  final String? currentPath;
  final int? progressDone;
  final int? progressTotal;
  final CleanupResult? result;

  bool get isDone => phase == CleanupPhase.done && result != null;

  Map<String, Object?> toJson() => {
    'phase': phase.name,
    'message': message,
    'currentPath': currentPath,
    'progressDone': progressDone,
    'progressTotal': progressTotal,
    'result': result?.toJson(),
  };
}
