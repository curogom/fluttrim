import 'scan_result.dart';

enum ScanPhase { discovering, sizing, done }

class ScanEvent {
  const ScanEvent._({
    required this.phase,
    this.message,
    this.currentPath,
    this.currentProjectRoot,
    this.progressDone,
    this.progressTotal,
    this.result,
  });

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

  factory ScanEvent.done(ScanResult result) {
    return ScanEvent._(phase: ScanPhase.done, result: result);
  }

  final ScanPhase phase;
  final String? message;
  final String? currentPath;
  final String? currentProjectRoot;
  final int? progressDone;
  final int? progressTotal;
  final ScanResult? result;

  bool get isDone => phase == ScanPhase.done && result != null;

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
