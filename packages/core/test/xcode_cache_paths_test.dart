import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:test/test.dart';

void main() {
  group('xcode cache paths', () {
    test('returns null on non-mac platforms', () {
      final path = resolveXcodeDerivedDataPath(
        operatingSystem: 'linux',
        environment: const {'HOME': '/home/me'},
      );

      expect(path, isNull);
    });

    test('resolves DerivedData path on macOS', () {
      final path = resolveXcodeDerivedDataPath(
        operatingSystem: 'macos',
        environment: const {'HOME': '/Users/me'},
      );

      expect(path, '/Users/me/Library/Developer/Xcode/DerivedData');
    });
  });
}
