import 'dart:convert';
import 'dart:io';

import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('RunHistoryService', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fluttrim_history_test_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('lists scan/cleanup entries sorted by timestamp desc', () async {
      await _writeJson(p.join(tempDir.path, 'scan_1.json'), {
        'startedAt': '2026-02-10T00:00:00.000Z',
        'finishedAt': '2026-02-10T00:01:00.000Z',
        'profile': 'safe',
        'cancelled': false,
        'projects': [
          {'name': 'a'},
        ],
        'totalBytes': 1024,
      });

      await _writeJson(p.join(tempDir.path, 'cleanup_1.json'), {
        'startedAt': '2026-02-11T00:00:00.000Z',
        'finishedAt': '2026-02-11T00:01:00.000Z',
        'profile': 'safe',
        'items': [
          {'path': '/tmp/a'},
        ],
        'successCount': 1,
        'failureCount': 0,
        'skippedCount': 0,
        'reclaimedBytes': 512,
      });

      final service = RunHistoryService(baseDir: tempDir.path);
      final entries = await service.listRuns();

      expect(entries.length, 2);
      expect(entries.first.kind, RunHistoryKind.cleanup);
      expect(entries.last.kind, RunHistoryKind.scan);
      expect(entries.last.totalBytes, 1024);
      expect(entries.first.reclaimedBytes, 512);
    });

    test('computes delta for sequential scan runs', () async {
      await _writeJson(p.join(tempDir.path, 'scan_old.json'), {
        'finishedAt': '2026-02-10T00:01:00.000Z',
        'profile': 'safe',
        'cancelled': false,
        'projects': [],
        'totalBytes': 100,
      });

      await _writeJson(p.join(tempDir.path, 'scan_new.json'), {
        'finishedAt': '2026-02-11T00:01:00.000Z',
        'profile': 'safe',
        'cancelled': false,
        'projects': [],
        'totalBytes': 250,
      });

      final service = RunHistoryService(baseDir: tempDir.path);
      final entries = await service.listRuns();

      final latestScan = entries.firstWhere(
        (e) => e.fileName == 'scan_new.json',
      );
      final oldScan = entries.firstWhere((e) => e.fileName == 'scan_old.json');

      expect(latestScan.deltaBytesFromPreviousScan, 150);
      expect(oldScan.deltaBytesFromPreviousScan, isNull);
    });
  });
}

Future<void> _writeJson(String path, Map<String, Object?> json) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString('${jsonEncode(json)}\n');
}
