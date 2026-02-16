import 'dart:convert';
import 'dart:io';

import '../models/fvm_result.dart';

class FvmService {
  FvmService({CommandRunner commandRunner = const SystemCommandRunner()})
    : _commandRunner = commandRunner;

  final CommandRunner _commandRunner;

  Future<FvmRemovalResult> removeSdk(
    String sdkName, {
    bool force = false,
  }) async {
    final normalized = sdkName.trim();
    if (normalized.isEmpty) {
      return const FvmRemovalResult(
        sdkName: '',
        success: false,
        exitCode: 64,
        error: 'SDK name must not be empty.',
      );
    }

    final executablePath = await _commandRunner.resolveExecutable('fvm');
    if (executablePath == null) {
      return FvmRemovalResult(
        sdkName: normalized,
        success: false,
        exitCode: 127,
        error: 'fvm executable not found.',
      );
    }

    final args = <String>['remove', normalized];
    if (force) {
      args.add('--force');
    }

    try {
      final result = await _commandRunner.run(executablePath, args);
      return FvmRemovalResult(
        sdkName: normalized,
        success: result.exitCode == 0,
        exitCode: result.exitCode,
        stdout: _cleanOutput(result.stdout),
        stderr: _cleanOutput(result.stderr),
      );
    } on Exception catch (e) {
      return FvmRemovalResult(
        sdkName: normalized,
        success: false,
        exitCode: 1,
        error: e.toString(),
      );
    }
  }

  Future<FvmResult> inspect({List<String> projectRoots = const []}) async {
    final executablePath = await _commandRunner.resolveExecutable('fvm');
    if (executablePath == null) {
      return const FvmResult(
        available: false,
        executablePath: null,
        version: null,
        installedSdks: [],
        projectUsages: [],
      );
    }

    try {
      final version = await _readVersion(executablePath);
      final installed = await _readInstalledSdks(executablePath);
      final usages = await _readProjectUsages(executablePath, projectRoots);

      final installedByName = <String, FvmInstalledSdk>{
        for (final item in installed) item.name: item,
      };
      final bySdk = <String, List<String>>{};
      for (final usage in usages) {
        final pinned = usage.pinnedVersion;
        if (pinned == null || pinned.isEmpty) continue;
        bySdk.putIfAbsent(pinned, () => []).add(usage.projectRoot);
      }

      final mergedInstalled = installedByName.values.map((sdk) {
        final usedBy = bySdk[sdk.name] ?? const <String>[];
        return FvmInstalledSdk(
          name: sdk.name,
          directory: sdk.directory,
          type: sdk.type,
          isSetup: sdk.isSetup,
          flutterSdkVersion: sdk.flutterSdkVersion,
          dartSdkVersion: sdk.dartSdkVersion,
          usedByProjectRoots: usedBy,
        );
      }).toList()..sort((a, b) => a.name.compareTo(b.name));

      final normalizedUsages = usages.map((usage) {
        final pinned = usage.pinnedVersion;
        final installedLocally =
            pinned != null &&
            pinned.isNotEmpty &&
            installedByName.containsKey(pinned);
        return FvmProjectUsage(
          projectRoot: usage.projectRoot,
          projectName: usage.projectName,
          hasConfig: usage.hasConfig,
          isFlutterProject: usage.isFlutterProject,
          pinnedVersion: usage.pinnedVersion,
          installedLocally: installedLocally,
        );
      }).toList()..sort((a, b) => a.projectName.compareTo(b.projectName));

      return FvmResult(
        available: true,
        executablePath: executablePath,
        version: version,
        installedSdks: mergedInstalled,
        projectUsages: normalizedUsages,
      );
    } on Exception catch (e) {
      return FvmResult(
        available: true,
        executablePath: executablePath,
        version: null,
        installedSdks: const [],
        projectUsages: const [],
        error: e.toString(),
      );
    }
  }

  Future<String?> _readVersion(String executablePath) async {
    final result = await _commandRunner.run(executablePath, const [
      '--version',
    ]);
    if (result.exitCode != 0) return null;
    final raw = (result.stdout as String).trim();
    if (raw.isEmpty) return null;
    return raw.split(RegExp(r'[\r\n]+')).first.trim();
  }

  Future<List<FvmInstalledSdk>> _readInstalledSdks(
    String executablePath,
  ) async {
    final result = await _commandRunner.run(executablePath, const [
      'api',
      'list',
      '--compress',
    ]);
    if (result.exitCode != 0) {
      throw FvmServiceException('fvm api list failed: ${result.stderr}');
    }

    final decoded = _decodeJsonObject(result.stdout);
    final versionsRaw = decoded['versions'];
    if (versionsRaw is! List) return const <FvmInstalledSdk>[];

    final out = <FvmInstalledSdk>[];
    for (final item in versionsRaw) {
      if (item is! Map) continue;
      final map = Map<String, Object?>.from(item.cast<String, Object?>());
      final name = _asString(map['name']);
      final directory = _asString(map['directory']);
      if (name == null || directory == null) continue;
      out.add(
        FvmInstalledSdk(
          name: name,
          directory: directory,
          type: _asString(map['type']) ?? 'unknown',
          isSetup: map['isSetup'] == true,
          flutterSdkVersion: _asString(map['flutterSdkVersion']),
          dartSdkVersion: _asString(map['dartSdkVersion']),
          usedByProjectRoots: const [],
        ),
      );
    }
    return out;
  }

  Future<List<FvmProjectUsage>> _readProjectUsages(
    String executablePath,
    List<String> projectRoots,
  ) async {
    final out = <FvmProjectUsage>[];
    for (final projectRoot in projectRoots) {
      final result = await _commandRunner.run(executablePath, const [
        'api',
        'project',
        '--compress',
      ], workingDirectory: projectRoot);
      if (result.exitCode != 0) {
        out.add(
          FvmProjectUsage(
            projectRoot: projectRoot,
            projectName: _basename(projectRoot),
            hasConfig: false,
            isFlutterProject: false,
            pinnedVersion: null,
            installedLocally: false,
          ),
        );
        continue;
      }

      final decoded = _decodeJsonObject(result.stdout);
      final projectRaw = decoded['project'];
      if (projectRaw is! Map) {
        out.add(
          FvmProjectUsage(
            projectRoot: projectRoot,
            projectName: _basename(projectRoot),
            hasConfig: false,
            isFlutterProject: false,
            pinnedVersion: null,
            installedLocally: false,
          ),
        );
        continue;
      }

      final projectMap = Map<String, Object?>.from(
        projectRaw.cast<String, Object?>(),
      );
      out.add(
        FvmProjectUsage(
          projectRoot: projectRoot,
          projectName: _asString(projectMap['name']) ?? _basename(projectRoot),
          hasConfig: projectMap['hasConfig'] == true,
          isFlutterProject: projectMap['isFlutter'] == true,
          pinnedVersion: _asString(projectMap['pinnedVersion']),
          installedLocally: false,
        ),
      );
    }
    return out;
  }
}

class FvmServiceException implements Exception {
  FvmServiceException(this.message);

  final String message;

  @override
  String toString() => 'FvmServiceException: $message';
}

abstract class CommandRunner {
  const CommandRunner();

  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  });

  Future<String?> resolveExecutable(String executable);
}

class SystemCommandRunner extends CommandRunner {
  const SystemCommandRunner();

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) {
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
    );
  }

  @override
  Future<String?> resolveExecutable(String executable) async {
    final locator = Platform.isWindows ? 'where' : 'which';
    try {
      final result = await Process.run(locator, [executable]);
      if (result.exitCode != 0) return null;
      final text = (result.stdout as String).trim();
      if (text.isEmpty) return null;
      return text.split(RegExp(r'[\r\n]+')).first;
    } on ProcessException {
      return null;
    }
  }
}

Map<String, Object?> _decodeJsonObject(Object? input) {
  final text = (input as String?)?.trim() ?? '';
  if (text.isEmpty) {
    return const <String, Object?>{};
  }
  final decoded = jsonDecode(text);
  if (decoded is! Map) {
    return const <String, Object?>{};
  }
  return Map<String, Object?>.from(decoded.cast<String, Object?>());
}

String? _asString(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

String _basename(String path) {
  if (path.isEmpty) return path;
  var normalized = path.replaceAll('\\', '/');
  while (normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  if (normalized.isEmpty) return path;
  final idx = normalized.lastIndexOf('/');
  if (idx < 0 || idx == normalized.length - 1) return normalized;
  return normalized.substring(idx + 1);
}

String? _cleanOutput(Object? value) {
  final text = (value as String?)?.trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}
