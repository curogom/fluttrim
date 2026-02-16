import 'dart:io';

import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('CleanupExecutor', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'fluttrim_executor_test_',
      );
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test(
      'permanent mode deletes allowlisted paths and reports reclaimed bytes',
      () async {
        final projectRoot = Directory(p.join(tempDir.path, 'my_app'));
        await projectRoot.create(recursive: true);
        final buildFile = File(p.join(projectRoot.path, 'build', 'a.bin'));
        await buildFile.parent.create(recursive: true);
        await buildFile.writeAsBytes(List<int>.filled(16, 1));

        final plan = CleanupPlan(
          createdAt: DateTime.now().toUtc(),
          profile: Profile.safe,
          deleteMode: DeleteMode.permanent,
          items: [
            CleanupPlanItem(
              targetId: 'project.build',
              category: CacheCategory.project,
              risk: Risk.low,
              path: p.join(projectRoot.path, 'build'),
              sizeBytes: 16,
              projectRootPath: projectRoot.path,
            ),
          ],
        );

        final executor = CleanupExecutor();
        final events = await executor.execute(plan).toList();
        final result = events.lastWhere((e) => e.isDone).result!;

        expect(result.successCount, 1);
        expect(result.failureCount, 0);
        expect(result.reclaimedBytes, 16);
        expect(
          await Directory(p.join(projectRoot.path, 'build')).exists(),
          isFalse,
        );
      },
    );

    test(
      'rejects non-allowlisted project path even when targetId is valid',
      () async {
        final projectRoot = Directory(p.join(tempDir.path, 'my_app'));
        await projectRoot.create(recursive: true);
        final rogue = Directory(p.join(projectRoot.path, 'rogue'));
        await rogue.create(recursive: true);

        final plan = CleanupPlan(
          createdAt: DateTime.now().toUtc(),
          profile: Profile.safe,
          deleteMode: DeleteMode.permanent,
          items: [
            CleanupPlanItem(
              targetId: 'project.build',
              category: CacheCategory.project,
              risk: Risk.low,
              path: rogue.path,
              sizeBytes: 1,
              projectRootPath: projectRoot.path,
            ),
          ],
        );

        final executor = CleanupExecutor();
        final events = await executor.execute(plan).toList();
        final result = events.lastWhere((e) => e.isDone).result!;

        expect(result.successCount, 0);
        expect(result.failureCount, 1);
        expect(await rogue.exists(), isTrue);
      },
    );

    test('rejects non-allowlisted global cache path', () async {
      final rogue = Directory(p.join(tempDir.path, 'rogue_global'));
      await rogue.create(recursive: true);

      final plan = CleanupPlan(
        createdAt: DateTime.now().toUtc(),
        profile: Profile.aggressive,
        deleteMode: DeleteMode.permanent,
        items: [
          CleanupPlanItem(
            targetId: globalPubCacheTargetId,
            category: CacheCategory.global,
            risk: Risk.high,
            path: rogue.path,
            sizeBytes: 1,
          ),
        ],
      );

      final executor = CleanupExecutor();
      final events = await executor.execute(plan).toList();
      final result = events.lastWhere((e) => e.isDone).result!;

      expect(result.successCount, 0);
      expect(result.failureCount, 1);
      expect(await rogue.exists(), isTrue);
    });

    test(
      'blocks unknown-attribution target unless allowUnknown is enabled',
      () async {
        final projectRoot = Directory(p.join(tempDir.path, 'my_app'));
        await projectRoot.create(recursive: true);
        final buildDir = Directory(p.join(projectRoot.path, 'build'));
        await buildDir.create(recursive: true);
        await File(
          p.join(buildDir.path, 'a.bin'),
        ).writeAsBytes(List<int>.filled(4, 1));

        final plan = CleanupPlan(
          createdAt: DateTime.now().toUtc(),
          profile: Profile.safe,
          deleteMode: DeleteMode.permanent,
          items: [
            CleanupPlanItem(
              targetId: 'project.build',
              category: CacheCategory.project,
              risk: Risk.low,
              path: buildDir.path,
              sizeBytes: 4,
              attributionStatus: AttributionStatus.unknown,
              projectRootPath: projectRoot.path,
            ),
          ],
        );

        final executor = CleanupExecutor();

        final blockedEvents = await executor.execute(plan).toList();
        final blockedResult = blockedEvents.lastWhere((e) => e.isDone).result!;
        expect(blockedResult.successCount, 0);
        expect(blockedResult.failureCount, 1);
        expect(await buildDir.exists(), isTrue);

        final allowedEvents = await executor
            .execute(plan, allowUnknown: true)
            .toList();
        final allowedResult = allowedEvents.lastWhere((e) => e.isDone).result!;
        expect(allowedResult.successCount, 1);
        expect(allowedResult.failureCount, 0);
        expect(await buildDir.exists(), isFalse);
      },
    );
  });
}
