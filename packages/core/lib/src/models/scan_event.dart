import 'scan_result.dart';

/// Progress phase for a scan stream.
enum ScanPhase { discovering, sizing, done }

/// Streaming event emitted by [ScanService.scan].
class ScanEvent {
  /// Internal constructor used by named factories.
  const ScanEvent._({
    required this.phase,
    this.message,
    this.currentPath,
    this.currentProjectRoot,
    this.progressDone,
    this.progressTotal,
    this.result,
  });

  /// Emits a project discovery event.
  factory ScanEvent.discovering({
    String? message,
    String? currentPath,
    int? progressDone,
    int? progressTotal,
  }) {
    return ScanEvent._(
      phase: ScanPhase.discovering,
      message: message,
      currentPath: currentPath,
      progressDone: progressDone,
      progressTotal: progressTotal,
    );
  }

  /// Emits a sizing event while scanning targets.
  factory ScanEvent.sizing({
    String? message,
    String? currentProjectRoot,
    String? currentPath,
    int? progressDone,
    int? progressTotal,
  }) {
    return ScanEvent._(
      phase: ScanPhase.sizing,
      message: message,
      currentProjectRoot: currentProjectRoot,
      currentPath: currentPath,
      progressDone: progressDone,
      progressTotal: progressTotal,
    );
  }

  /// Emits a completion event with final [result].
  factory ScanEvent.done(ScanResult result) {
    return ScanEvent._(phase: ScanPhase.done, result: result);
  }

  /// Current scan phase.
  final ScanPhase phase;

  /// Optional human-readable progress message.
  final String? message;

  /// Path currently being processed.
  final String? currentPath;

  /// Current project root path during sizing.
  final String? currentProjectRoot;

  /// 1-based completed step count when known.
  final int? progressDone;

  /// Total step count when known.
  final int? progressTotal;

  /// Final scan result when [phase] is [ScanPhase.done].
  final ScanResult? result;

  /// Returns `true` when this event carries final result data.
  bool get isDone => phase == ScanPhase.done && result != null;

  /// Serializes event payload as JSON.
  Map<String, Object?> toJson() => {
    'phase': phase.name,
    'message': message,
    'currentPath': currentPath,
    'currentProjectRoot': currentProjectRoot,
    'progressDone': progressDone,
    'progressTotal': progressTotal,
    'result': result?.toJson(),
  };
}
