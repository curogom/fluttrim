import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/cleanup_result.dart';
import '../models/scan_result.dart';

/// Persists scan/cleanup results as JSON log files.
class RunLogWriter {
  /// Creates a log writer.
  ///
  /// When [baseDir] is omitted, [defaultRunLogDir] is used.
  const RunLogWriter({this.baseDir});

  /// Optional base directory for log files.
  final String? baseDir;

  /// Writes one [ScanResult] log file and returns created file handle.
  Future<File> writeScanResult(ScanResult result) async {
    return _write(
      prefix: 'scan',
      timestamp: result.finishedAt,
      json: result.toJson(),
    );
  }

  /// Writes one [CleanupResult] log file and returns created file handle.
  Future<File> writeCleanupResult(CleanupResult result) async {
    return _write(
      prefix: 'cleanup',
      timestamp: result.finishedAt,
      json: result.toJson(),
    );
  }

  Future<File> _write({
    required String prefix,
    required DateTime timestamp,
    required Map<String, Object?> json,
  }) async {
    final root = baseDir ?? defaultRunLogDir();
    final dir = Directory(root);
    await dir.create(recursive: true);

    final fileName = '${prefix}_${_safeTimestamp(timestamp)}.json';
    final file = File(p.join(dir.path, fileName));
    final encoder = const JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(json)}\n');
    return file;
  }
}

/// Returns platform-specific default log directory for Fluttrim.
String defaultRunLogDir() {
  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    if (appData != null && appData.isNotEmpty) {
      return p.normalize(p.join(appData, 'fluttrim', 'logs'));
    }
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return p.normalize(p.join(localAppData, 'fluttrim', 'logs'));
    }
  }
  final home = Platform.environment['HOME'] ?? Directory.current.path;
  return p.normalize(p.join(home, '.fluttrim', 'logs'));
}

String _safeTimestamp(DateTime value) {
  final utc = value.toUtc().toIso8601String();
  return utc.replaceAll(':', '-');
}
