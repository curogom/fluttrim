import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:test/test.dart';

void main() {
  group('Global cache path resolver', () {
    test('resolves linux paths with environment overrides', () {
      final paths = resolveGlobalCachePaths(
        operatingSystem: 'linux',
        environment: const {
          'HOME': '/home/dev',
          'PUB_CACHE': '/cache/pub',
          'GRADLE_USER_HOME': '/cache/gradle',
        },
      );
      final byId = {for (final path in paths) path.targetId: path.path};

      expect(byId[globalPubCacheTargetId], '/cache/pub');
      expect(byId[globalGradleUserHomeTargetId], '/cache/gradle');
      expect(byId[globalCocoaPodsHomeTargetId], '/home/dev/.cocoapods');
      expect(byId.containsKey(globalCocoaPodsCacheTargetId), isFalse);
    });

    test('resolves macOS CocoaPods cache paths', () {
      final paths = resolveGlobalCachePaths(
        operatingSystem: 'macos',
        environment: const {'HOME': '/Users/dev'},
      );
      final byId = {for (final path in paths) path.targetId: path.path};

      expect(
        byId[globalCocoaPodsCacheTargetId],
        '/Users/dev/Library/Caches/CocoaPods',
      );
      expect(byId[globalCocoaPodsHomeTargetId], '/Users/dev/.cocoapods');
    });
  });
}
