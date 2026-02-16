import 'dart:io';

import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('DerivedData attribution', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fluttrim_attr_test_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('attributes to Flutter project via WorkspacePath', () async {
      final projectRoot = Directory(p.join(tempDir.path, 'my_app'));
      await projectRoot.create(recursive: true);
      await File(
        p.join(projectRoot.path, 'pubspec.yaml'),
      ).writeAsString('name: my_app\n');
      await Directory(p.join(projectRoot.path, 'ios')).create(recursive: true);
      await File(
        p.join(projectRoot.path, '.metadata'),
      ).writeAsString('version: 1\n');

      final workspacePath = p.join(
        projectRoot.path,
        'ios',
        'Runner.xcworkspace',
      );
      await Directory(workspacePath).create(recursive: true);

      final derived = Directory(
        p.join(tempDir.path, 'DerivedData', 'MyApp-abc'),
      );
      await derived.create(recursive: true);
      await File(p.join(derived.path, 'Info.plist')).writeAsString('''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>WorkspacePath</key>
  <string>$workspacePath</string>
</dict>
</plist>
''');

      final result = await attributeDerivedDataDirectory(derived);

      expect(result.status, AttributionStatus.attributed);
      expect(result.projectRootPath, projectRoot.path);
      expect(result.confidence, closeTo(0.95, 0.001));
    });

    test('returns unknown when no project evidence exists', () async {
      final derived = Directory(
        p.join(tempDir.path, 'DerivedData', 'Unknown-abc'),
      );
      await derived.create(recursive: true);
      await File(p.join(derived.path, 'Info.plist')).writeAsString('''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>WorkspacePath</key>
  <string>/tmp/not_a_flutter_project/Runner.xcworkspace</string>
</dict>
</plist>
''');

      final result = await attributeDerivedDataDirectory(derived);

      expect(result.status, AttributionStatus.unknown);
      expect(result.projectRootPath, isNull);
    });
  });
}
