import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../logs/run_log_writer.dart';
import '../models/history_entry.dart';

class RunHistoryService {
  const RunHistoryService({this.baseDir});

  final String? baseDir;

  Future<List<RunHistoryEntry>> listRuns({int limit = 100}) async {
    if (limit <= 0) {
      return const <RunHistoryEntry>[];
    }

    final dir = Directory(baseDir ?? defaultRunLogDir());
    if (!await dir.exists()) {
      return const <RunHistoryEntry>[];
    }

    final entries = <RunHistoryEntry>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;

      final fileName = p.basename(entity.path);
      if (!fileName.endsWith('.json')) continue;
      if (!fileName.startsWith('scan_') && !fileName.startsWith('cleanup_')) {
        continue;
      }

      final parsed = await _parseLogFile(entity, fileName);
      if (parsed != null) {
        entries.add(parsed);
      }
    }

    final withDelta = _applyScanDeltas(entries);
    withDelta.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (withDelta.length > limit) {
      return withDelta.take(limit).toList(growable: false);
    }
    return withDelta;
  }
}

Future<RunHistoryEntry?> _parseLogFile(File file, String fileName) async {
  Map<String, Object?> json;
  try {
    final text = await file.readAsString();
    final decoded = jsonDecode(text);
    if (decoded is! Map) {
      return null;
    }
    json = Map<String, Object?>.from(decoded.cast<String, Object?>());
  } on Exception {
    return null;
  }

  final timestamp =
      _parseTimestamp(json['finishedAt']) ??
      _parseTimestamp(json['startedAt']) ??
      (await file.lastModified()).toUtc();

  if (fileName.startsWith('scan_')) {
    final projects = _asList(json['projects']);
    final profile = (_asString(json['profile']) ?? 'safe').toLowerCase();
    return RunHistoryEntry(
      filePath: p.normalize(file.path),
      fileName: fileName,
      kind: RunHistoryKind.scan,
      timestamp: timestamp,
      profile: profile,
      totalBytes: _asInt(json['totalBytes']),
      projectCount: projects.length,
      cancelled: json['cancelled'] == true,
    );
  }

  final items = _asList(json['items']);
  final profile = (_asString(json['profile']) ?? 'safe').toLowerCase();
  return RunHistoryEntry(
    filePath: p.normalize(file.path),
    fileName: fileName,
    kind: RunHistoryKind.cleanup,
    timestamp: timestamp,
    profile: profile,
    reclaimedBytes: _asInt(json['reclaimedBytes']),
    itemCount: items.length,
    successCount: _asInt(json['successCount']),
    failureCount: _asInt(json['failureCount']),
    skippedCount: _asInt(json['skippedCount']),
  );
}

List<RunHistoryEntry> _applyScanDeltas(List<RunHistoryEntry> entries) {
  final scans =
      entries
          .where((entry) => entry.kind == RunHistoryKind.scan)
          .toList(growable: false)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final deltaByFilePath = <String, int?>{};
  int? previous;
  for (final scan in scans) {
    final current = scan.totalBytes;
    if (current == null || previous == null) {
      deltaByFilePath[scan.filePath] = null;
    } else {
      deltaByFilePath[scan.filePath] = current - previous;
    }
    previous = current;
  }

  return entries
      .map(
        (entry) => entry.copyWith(
          deltaBytesFromPreviousScan: deltaByFilePath[entry.filePath],
        ),
      )
      .toList(growable: false);
}

DateTime? _parseTimestamp(Object? value) {
  final text = _asString(value);
  if (text == null) return null;
  return DateTime.tryParse(text)?.toUtc();
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String? _asString(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

List<Object?> _asList(Object? value) {
  if (value is List) {
    return List<Object?>.from(value);
  }
  return const <Object?>[];
}
