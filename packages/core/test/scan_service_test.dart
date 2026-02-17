import 'dart:io';

import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ScanService', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fluttrim_core_test_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test(
      'discovers Flutter projects by pubspec.yaml + (.metadata OR ios/ OR android/)',
      () async {
        await _createFlutterProject(
          tempDir,
          dirName: 'p1',
          pubspecName: 'p1',
          withMetadata: true,
        );
        await _createFlutterProject(
          tempDir,
          dirName: 'p2',
          pubspecName: 'p2',
          withAndroidDir: true,
        );
        await _createPubspecOnly(
          tempDir,
          dirName: 'not_flutter',
          pubspecName: 'nope',
        );

        final service = ScanService();
        final events = await service
            .scan(
              ScanRequest(
                roots: [tempDir.path],
                profile: Profile.safe,
                computeSizes: false,
              ),
            )
            .toList();
        final done = events.lastWhere((e) => e.isDone).result!;

        expect(done.cancelled, isFalse);
        expect(done.projects.map((p) => p.name).toSet(), {'p1', 'p2'});
      },
    );

    test('respects maxDepth during discovery', () async {
      final deep = Directory(p.join(tempDir.path, 'a', 'b', 'c'));
      await deep.create(recursive: true);
      await _createFlutterProject(
        deep,
        dirName: 'deep_proj',
        pubspecName: 'deep_proj',
        withMetadata: true,
      );

      final service = ScanService();
      final shallow = await service
          .scan(
            ScanRequest(
              roots: [tempDir.path],
              profile: Profile.safe,
              computeSizes: false,
              maxDepth: 1,
            ),
          )
          .toList();
      final shallowDone = shallow.lastWhere((e) => e.isDone).result!;
      expect(shallowDone.projects, isEmpty);

      final deepScan = await service
          .scan(
            ScanRequest(
              roots: [tempDir.path],
              profile: Profile.safe,
              computeSizes: false,
              maxDepth: 5,
            ),
          )
          .toList();
      final deepDone = deepScan.lastWhere((e) => e.isDone).result!;
      expect(deepDone.projects.map((p) => p.name).toSet(), {'deep_proj'});
    });

    test('respects exclusions', () async {
      await _createFlutterProject(
        tempDir,
        dirName: 'skipme',
        pubspecName: 'skipme',
        withMetadata: true,
      );
      await _createFlutterProject(
        tempDir,
        dirName: 'keepme',
        pubspecName: 'keepme',
        withMetadata: true,
      );

      final service = ScanService();
      final events = await service
          .scan(
            ScanRequest(
              roots: [tempDir.path],
              profile: Profile.safe,
              computeSizes: false,
              exclusions: const ['skipme'],
            ),
          )
          .toList();
      final done = events.lastWhere((e) => e.isDone).result!;

      expect(done.projects.map((p) => p.name).toSet(), {'keepme'});
    });

    test('skips Flutter projects under packages directories', () async {
      final packagesDir = Directory(p.join(tempDir.path, 'packages'));
      await packagesDir.create(recursive: true);
      await _createFlutterProject(
        packagesDir,
        dirName: 'inside_packages',
        pubspecName: 'inside_packages',
        withMetadata: true,
      );
      await _createFlutterProject(
        tempDir,
        dirName: 'outside_packages',
        pubspecName: 'outside_packages',
        withMetadata: true,
      );

      final service = ScanService();
      final events = await service
          .scan(
            ScanRequest(
              roots: [tempDir.path],
              profile: Profile.safe,
              computeSizes: false,
            ),
          )
          .toList();
      final done = events.lastWhere((e) => e.isDone).result!;

      expect(done.projects.map((p) => p.name).toSet(), {'outside_packages'});
    });

    test(
      'skips direct roots that are under packages when no melos config',
      () async {
        final packagesDir = Directory(p.join(tempDir.path, 'packages'));
        await packagesDir.create(recursive: true);
        final insidePackages = await _createFlutterProject(
          packagesDir,
          dirName: 'direct_root_package',
          pubspecName: 'direct_root_package',
          withMetadata: true,
        );

        final service = ScanService();
        final events = await service
            .scan(
              ScanRequest(
                roots: [insidePackages.path],
                profile: Profile.safe,
                computeSizes: false,
              ),
            )
            .toList();
        final done = events.lastWhere((e) => e.isDone).result!;

        expect(done.projects, isEmpty);
      },
    );

    test(
      'skips symlinked roots that resolve into packages when no melos config',
      () async {
        final packagesDir = Directory(p.join(tempDir.path, 'packages'));
        await packagesDir.create(recursive: true);
        final packageProject = await _createFlutterProject(
          packagesDir,
          dirName: 'symlink_target',
          pubspecName: 'symlink_target',
          withMetadata: true,
        );

        final aliasPath = p.join(tempDir.path, 'alias_project');
        final alias = Link(aliasPath);
        await alias.create(packageProject.path, recursive: true);

        final service = ScanService();
        final events = await service
            .scan(
              ScanRequest(
                roots: [alias.path],
                profile: Profile.safe,
                computeSizes: false,
              ),
            )
            .toList();
        final done = events.lastWhere((e) => e.isDone).result!;

        expect(done.projects, isEmpty);
      },
      skip: Platform.isWindows,
    );

    test(
      'allows melos workspace packages while keeping other packages excluded',
      () async {
        final melosFile = File(p.join(tempDir.path, 'melos.yaml'));
        await melosFile.writeAsString('''
name: test_workspace
packages:
  - packages/internal_*
''');

        final packagesDir = Directory(p.join(tempDir.path, 'packages'));
        await packagesDir.create(recursive: true);
        await _createFlutterProject(
          packagesDir,
          dirName: 'internal_one',
          pubspecName: 'internal_one',
          withMetadata: true,
        );
        await _createFlutterProject(
          packagesDir,
          dirName: 'external_two',
          pubspecName: 'external_two',
          withMetadata: true,
        );

        final service = ScanService();
        final events = await service
            .scan(
              ScanRequest(
                roots: [tempDir.path],
                profile: Profile.safe,
                computeSizes: false,
              ),
            )
            .toList();
        final done = events.lastWhere((e) => e.isDone).result!;

        expect(done.projects.map((p) => p.name).toSet(), {'internal_one'});
      },
    );

    test(
      'resolves melos workspace when root points directly to packages child',
      () async {
        final melosFile = File(p.join(tempDir.path, 'melos.yaml'));
        await melosFile.writeAsString('''
name: test_workspace
packages:
  - packages/**
''');

        final packagesDir = Directory(p.join(tempDir.path, 'packages'));
        await packagesDir.create(recursive: true);
        final workspacePackage = await _createFlutterProject(
          packagesDir,
          dirName: 'direct_allowed',
          pubspecName: 'direct_allowed',
          withMetadata: true,
        );

        final service = ScanService();
        final events = await service
            .scan(
              ScanRequest(
                roots: [workspacePackage.path],
                profile: Profile.safe,
                computeSizes: false,
              ),
            )
            .toList();
        final done = events.lastWhere((e) => e.isDone).result!;

        expect(done.projects.map((p) => p.name).toSet(), {'direct_allowed'});
      },
    );

    test(
      'ignores unreadable directories without crashing scan',
      () async {
        final blocked = Directory(p.join(tempDir.path, 'blocked'));
        await blocked.create(recursive: true);
        await File(p.join(blocked.path, 'note.txt')).writeAsString('secret');

        await _createFlutterProject(
          tempDir,
          dirName: 'readable_project',
          pubspecName: 'readable_project',
          withMetadata: true,
        );

        final chmodResult = await Process.run('chmod', ['000', blocked.path]);
        if (chmodResult.exitCode != 0) {
          return;
        }

        try {
          final service = ScanService();
          final events = await service
              .scan(
                ScanRequest(
                  roots: [tempDir.path],
                  profile: Profile.safe,
                  computeSizes: false,
                ),
              )
              .toList();
          final done = events.lastWhere((e) => e.isDone).result!;

          expect(done.cancelled, isFalse);
          expect(done.projects.map((p) => p.name).toSet(), {
            'readable_project',
          });
        } finally {
          await Process.run('chmod', ['700', blocked.path]);
        }
      },
      skip: Platform.isWindows,
    );

    test('computes SAFE target sizes', () async {
      final project = await _createFlutterProject(
        tempDir,
        dirName: 'sizes',
        pubspecName: 'sizes',
        withMetadata: true,
      );
      await _writeSizedFile(p.join(project.path, 'build', 'a.bin'), 5);
      await _writeSizedFile(p.join(project.path, '.dart_tool', 'b.bin'), 7);
      await _writeSizedFile(p.join(project.path, '.flutter-plugins'), 3);
      await _writeSizedFile(
        p.join(project.path, '.flutter-plugins-dependencies'),
        4,
      );

      final service = ScanService();
      final events = await service
          .scan(
            ScanRequest(
              roots: [tempDir.path],
              profile: Profile.safe,
              computeSizes: true,
            ),
          )
          .toList();
      final done = events.lastWhere((e) => e.isDone).result!;

      final proj = done.projects.singleWhere((p) => p.name == 'sizes');
      final byId = {for (final t in proj.targets) t.targetId: t};

      expect(byId['project.build']!.sizeBytes, 5);
      expect(byId['project.dart_tool']!.sizeBytes, 7);
      expect(byId['project.flutter_plugins']!.sizeBytes, 3);
      expect(byId['project.flutter_plugins_deps']!.sizeBytes, 4);
      expect(proj.totalBytes, 19);
    });

    test('can be cancelled (returns cancelled=true)', () async {
      await _createFlutterProject(
        tempDir,
        dirName: 'p',
        pubspecName: 'p',
        withMetadata: true,
      );

      final token = CancellationToken()..cancel();
      final service = ScanService();
      final events = await service
          .scan(
            ScanRequest(roots: [tempDir.path], profile: Profile.safe),
            cancellationToken: token,
          )
          .toList();
      final done = events.lastWhere((e) => e.isDone).result!;

      expect(done.cancelled, isTrue);
    });

    test('can include global cache targets when requested', () async {
      final service = ScanService();
      final events = await service
          .scan(
            const ScanRequest(
              roots: <String>[],
              profile: Profile.aggressive,
              includeGlobal: true,
              computeSizes: false,
              maxDepth: 0,
            ),
          )
          .toList();
      final done = events.lastWhere((e) => e.isDone).result!;

      expect(done.globalTargets, isNotEmpty);
      expect(done.globalTargets.map((target) => target.category).toSet(), {
        CacheCategory.global,
      });
    });
  });
}

Future<Directory> _createFlutterProject(
  Directory root, {
  required String dirName,
  required String pubspecName,
  bool withMetadata = false,
  bool withIosDir = false,
  bool withAndroidDir = false,
}) async {
  final dir = Directory(p.join(root.path, dirName));
  await dir.create(recursive: true);
  await File(
    p.join(dir.path, 'pubspec.yaml'),
  ).writeAsString('name: $pubspecName\n');
  if (withMetadata) {
    await File(p.join(dir.path, '.metadata')).writeAsString('version: 1\n');
  }
  if (withIosDir) {
    await Directory(p.join(dir.path, 'ios')).create(recursive: true);
  }
  if (withAndroidDir) {
    await Directory(p.join(dir.path, 'android')).create(recursive: true);
  }

  // Create empty target dirs so existence checks pass.
  await Directory(p.join(dir.path, 'build')).create(recursive: true);
  await Directory(p.join(dir.path, '.dart_tool')).create(recursive: true);
  return dir;
}

Future<void> _createPubspecOnly(
  Directory root, {
  required String dirName,
  required String pubspecName,
}) async {
  final dir = Directory(p.join(root.path, dirName));
  await dir.create(recursive: true);
  await File(
    p.join(dir.path, 'pubspec.yaml'),
  ).writeAsString('name: $pubspecName\n');
}

Future<void> _writeSizedFile(String path, int bytes) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(List<int>.filled(bytes, 1));
}
