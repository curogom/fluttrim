import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:test/test.dart';

void main() {
  group('TargetRegistry', () {
    test('SAFE includes only SAFE targets', () {
      final ids = TargetRegistry.projectTargetsFor(
        Profile.safe,
      ).map((t) => t.id).toSet();
      expect(ids, {
        'project.build',
        'project.dart_tool',
        'project.flutter_plugins',
        'project.flutter_plugins_deps',
      });
    });

    test('MEDIUM includes SAFE + MEDIUM targets', () {
      final ids = TargetRegistry.projectTargetsFor(
        Profile.medium,
      ).map((t) => t.id).toSet();
      expect(
        ids,
        containsAll(<String>{
          'project.build',
          'project.dart_tool',
          'project.flutter_plugins',
          'project.flutter_plugins_deps',
          'project.idea',
          'project.android_gradle',
          'project.ios_pods',
          'project.ios_symlinks',
        }),
      );
    });

    test('AGGRESSIVE includes global cache targets', () {
      final ids = TargetRegistry.globalTargetsFor(
        Profile.aggressive,
      ).map((t) => t.id).toSet();
      expect(
        ids,
        containsAll(<String>{
          globalPubCacheTargetId,
          globalGradleUserHomeTargetId,
          globalCocoaPodsCacheTargetId,
          globalCocoaPodsHomeTargetId,
        }),
      );
    });

    test('AGGRESSIVE includes Xcode cache target', () {
      final ids = TargetRegistry.xcodeTargetsFor(
        Profile.aggressive,
      ).map((t) => t.id).toSet();
      expect(ids, contains(xcodeDerivedDataTargetId));
    });
  });
}
