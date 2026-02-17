import 'dart:io';

import '../global/global_cache_paths.dart';
import '../models/doctor_result.dart';
import '../xcode/xcode_cache_paths.dart';

/// Collects OS/tool/cache-path diagnostics used by CLI and GUI doctor views.
class DoctorService {
  /// Creates a doctor service.
  const DoctorService();

  /// Runs diagnostics and returns a structured [DoctorResult].
  Future<DoctorResult> run() async {
    final cachePaths = <CachePathStatus>[];
    final resolvedGlobals = resolveGlobalCachePaths();
    for (final entry in resolvedGlobals) {
      cachePaths.add(
        CachePathStatus(
          id: entry.targetId,
          path: entry.path,
          exists: await _existsPath(entry.path),
        ),
      );
    }
    cachePaths.addAll(await _platformSpecificCachePaths());

    final tools = <ToolStatus>[
      await _tool('dart'),
      await _tool('flutter'),
      await _tool('fvm'),
      if (Platform.isMacOS) ...[
        await _tool('xcodebuild'),
        await _tool('plutil'),
      ],
      if (Platform.isLinux) await _tool('gio'),
      if (Platform.isWindows) ...[
        await _tool('powershell'),
        await _tool('pwsh'),
      ],
    ];

    return DoctorResult(
      osName: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      cachePaths: cachePaths,
      tools: tools,
    );
  }
}

Future<bool> _existsPath(String path) async {
  if (path.isEmpty) return false;
  final type = await FileSystemEntity.type(path, followLinks: false);
  return type != FileSystemEntityType.notFound;
}

Future<List<CachePathStatus>> _platformSpecificCachePaths() async {
  final derivedData = resolveXcodeDerivedDataPath();
  if (derivedData != null) {
    return [
      CachePathStatus(
        id: xcodeDerivedDataTargetId,
        path: derivedData,
        exists: await _existsPath(derivedData),
      ),
    ];
  }
  return const <CachePathStatus>[];
}

Future<ToolStatus> _tool(String executable) async {
  final resolved = await _resolveExecutable(executable);
  return ToolStatus(
    name: executable,
    available: resolved != null,
    resolvedPath: resolved,
  );
}

Future<String?> _resolveExecutable(String executable) async {
  final locator = Platform.isWindows ? 'where' : 'which';
  try {
    final result = await Process.run(locator, [executable]);
    if (result.exitCode != 0) return null;
    final stdoutText = (result.stdout as String).trim();
    if (stdoutText.isEmpty) return null;
    return stdoutText.split(RegExp(r'[\r\n]+')).first;
  } on ProcessException {
    return null;
  }
}
