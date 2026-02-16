import 'dart:io';

import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:test/test.dart';

void main() {
  group('FvmService', () {
    test('returns unavailable when fvm executable is not found', () async {
      final service = FvmService(
        commandRunner: _FakeCommandRunner(
          executablePath: null,
          handlers: const {},
        ),
      );

      final result = await service.inspect(projectRoots: const ['/tmp/a']);

      expect(result.available, isFalse);
      expect(result.installedSdks, isEmpty);
      expect(result.projectUsages, isEmpty);
    });

    test('parses installed sdks and maps project pinned versions', () async {
      final fvmPath = '/usr/local/bin/fvm';
      final service = FvmService(
        commandRunner: _FakeCommandRunner(
          executablePath: fvmPath,
          handlers: {
            const _CommandKey('--version', null): ProcessResult(
              0,
              0,
              '3.2.1\n',
              '',
            ),
            const _CommandKey('api list --compress', null): ProcessResult(
              0,
              0,
              '''
{"size":"1.2 GB","versions":[
{"name":"3.35.3","directory":"/fvm/3.35.3","type":"release","dartSdkVersion":"3.9.2","flutterSdkVersion":"3.35.3","isSetup":true},
{"name":"3.29.2","directory":"/fvm/3.29.2","type":"release","dartSdkVersion":"3.7.2","flutterSdkVersion":"3.29.2","isSetup":true}
]}
''',
              '',
            ),
            const _CommandKey(
              'api project --compress',
              '/repo/app1',
            ): ProcessResult(0, 0, '''
{"project":{"name":"app1","isFlutter":true,"hasConfig":true,"pinnedVersion":"3.35.3"}}
''', ''),
            const _CommandKey(
              'api project --compress',
              '/repo/app2',
            ): ProcessResult(0, 0, '''
{"project":{"name":"app2","isFlutter":true,"hasConfig":true,"pinnedVersion":"missing"}}
''', ''),
          },
        ),
      );

      final result = await service.inspect(
        projectRoots: const ['/repo/app1', '/repo/app2'],
      );

      expect(result.available, isTrue);
      expect(result.version, '3.2.1');
      expect(result.installedSdks.length, 2);

      final sdk353 = result.installedSdks.singleWhere(
        (s) => s.name == '3.35.3',
      );
      expect(sdk353.usedByProjectRoots, ['/repo/app1']);
      expect(sdk353.isUsed, isTrue);

      final app2 = result.projectUsages.singleWhere(
        (p) => p.projectName == 'app2',
      );
      expect(app2.usesFvm, isTrue);
      expect(app2.installedLocally, isFalse);
    });

    test('removeSdk returns success when fvm remove exits with zero', () async {
      const fvmPath = '/usr/local/bin/fvm';
      final service = FvmService(
        commandRunner: _FakeCommandRunner(
          executablePath: fvmPath,
          handlers: {
            const _CommandKey('remove 3.35.3', null): ProcessResult(
              0,
              0,
              'removed',
              '',
            ),
          },
        ),
      );

      final result = await service.removeSdk('3.35.3');
      expect(result.success, isTrue);
      expect(result.exitCode, 0);
      expect(result.sdkName, '3.35.3');
    });

    test('removeSdk returns failure when fvm is unavailable', () async {
      final service = FvmService(
        commandRunner: _FakeCommandRunner(
          executablePath: null,
          handlers: const {},
        ),
      );

      final result = await service.removeSdk('3.35.3');
      expect(result.success, isFalse);
      expect(result.exitCode, 127);
    });
  });
}

class _FakeCommandRunner extends CommandRunner {
  _FakeCommandRunner({
    required String? executablePath,
    required Map<_CommandKey, ProcessResult> handlers,
  }) : _executablePath = executablePath,
       _handlers = handlers;

  final String? _executablePath;
  final Map<_CommandKey, ProcessResult> _handlers;

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    final key = _CommandKey(arguments.join(' '), workingDirectory);
    final result = _handlers[key];
    if (result != null) {
      return result;
    }
    return ProcessResult(
      0,
      64,
      '',
      'missing handler: ${key.args} (${key.cwd})',
    );
  }

  @override
  Future<String?> resolveExecutable(String executable) async => _executablePath;
}

class _CommandKey {
  const _CommandKey(this.args, this.cwd);

  final String args;
  final String? cwd;

  @override
  bool operator ==(Object other) {
    return other is _CommandKey && other.args == args && other.cwd == cwd;
  }

  @override
  int get hashCode => Object.hash(args, cwd);
}
