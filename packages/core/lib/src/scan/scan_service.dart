import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../cancellation/cancellation_token.dart';
import '../global/global_cache_paths.dart';
import '../models/cache_category.dart';
import '../models/cache_target.dart';
import '../models/scan_event.dart';
import '../models/scan_request.dart';
import '../models/scan_result.dart';
import '../targets/target_registry.dart';
import '../xcode/derived_data_attribution.dart';
import '../xcode/xcode_cache_paths.dart';
import 'exclude_matcher.dart';

/// Discovers Flutter projects and computes cache-target scan results.
class ScanService {
  /// Creates a scan service.
  const ScanService();

  /// Runs a scan and emits incremental [ScanEvent] updates.
  ///
  /// The final stream event is always [ScanPhase.done] carrying [ScanResult].
  Stream<ScanEvent> scan(
    ScanRequest request, {
    CancellationToken? cancellationToken,
  }) {
    final controller = StreamController<ScanEvent>();
    final token = cancellationToken ?? CancellationToken();

    () async {
      final startedAt = DateTime.now().toUtc();
      final projects = <ProjectScanResult>[];
      final xcodeTargets = <TargetScanResult>[];
      final globalTargets = <TargetScanResult>[];
      var cancelled = false;

      try {
        final exclude = ExcludeMatcher(request.exclusions);
        final projectRoots = <Directory>[];
        final workspaceCache = _MelosWorkspaceCache();

        controller.add(
          ScanEvent.discovering(message: 'Discovering Flutter projects...'),
        );

        for (final root in request.roots) {
          token.throwIfCancelled();
          final dir = Directory(root).absolute;
          if (!await _safeExistsDirectory(dir)) {
            controller.add(
              ScanEvent.discovering(
                message: 'Root does not exist, skipping.',
                currentPath: root,
              ),
            );
            continue;
          }
          final workspace = await workspaceCache.resolveForPath(dir.path);
          await _discoverUnder(
            dir,
            depth: 0,
            request: request,
            exclude: exclude,
            token: token,
            workspace: workspace,
            workspaceCache: workspaceCache,
            onProject: projectRoots.add,
            onEvent: controller.add,
          );
        }

        final projectTargets = TargetRegistry.projectTargetsFor(
          request.profile,
        ).toList();

        var projectIndex = 0;
        for (final projectRoot in projectRoots) {
          token.throwIfCancelled();
          projectIndex++;

          final name =
              await _readPubspecName(projectRoot) ??
              p.basename(projectRoot.path);
          controller.add(
            ScanEvent.sizing(
              message: 'Scanning project: $name',
              currentProjectRoot: projectRoot.path,
              progressDone: projectIndex,
              progressTotal: projectRoots.length,
            ),
          );

          final targetResults = <TargetScanResult>[];
          for (final target in projectTargets) {
            token.throwIfCancelled();

            final rel = target.projectRelativePath;
            if (target.category == CacheCategory.project && rel == null) {
              continue;
            }
            final absPath = target.category == CacheCategory.project
                ? p.normalize(p.join(projectRoot.path, rel))
                : '';

            controller.add(
              ScanEvent.sizing(
                message: 'Sizing: ${target.id}',
                currentProjectRoot: projectRoot.path,
                currentPath: absPath,
              ),
            );

            final (exists, sizeBytes, error) = await _scanTarget(
              target: target,
              absolutePath: absPath,
              computeSize: request.computeSizes,
              followSymlinks: request.followSymlinks,
              token: token,
              exclude: exclude,
            );

            targetResults.add(
              TargetScanResult(
                targetId: target.id,
                category: target.category,
                risk: target.risk,
                path: absPath,
                exists: exists,
                sizeBytes: sizeBytes,
                error: error,
              ),
            );
          }

          projects.add(
            ProjectScanResult(
              name: name,
              rootPath: p.normalize(projectRoot.path),
              targets: targetResults,
            ),
          );
        }

        if (request.includeGlobal) {
          final xcodeTargetDefs = TargetRegistry.xcodeTargetsFor(
            request.profile,
          ).toList();
          if (xcodeTargetDefs.isNotEmpty) {
            final xcodeResults = await _scanXcodeTargets(
              xcodeTargets: xcodeTargetDefs,
              request: request,
              token: token,
              exclude: exclude,
              onEvent: controller.add,
            );
            xcodeTargets.addAll(xcodeResults);
          }

          final globalById = <String, String>{
            for (final item in resolveGlobalCachePaths())
              item.targetId: p.normalize(item.path),
          };
          final globalTargetDefs = TargetRegistry.globalTargetsFor(
            request.profile,
          );

          for (final target in globalTargetDefs) {
            token.throwIfCancelled();
            final absPath = globalById[target.id];
            if (absPath == null || absPath.isEmpty) {
              continue;
            }

            controller.add(
              ScanEvent.sizing(
                message: 'Sizing global cache: ${target.id}',
                currentPath: absPath,
              ),
            );

            final (exists, sizeBytes, error) = await _scanTarget(
              target: target,
              absolutePath: absPath,
              computeSize: request.computeSizes,
              followSymlinks: request.followSymlinks,
              token: token,
              exclude: exclude,
            );

            globalTargets.add(
              TargetScanResult(
                targetId: target.id,
                category: target.category,
                risk: target.risk,
                path: absPath,
                exists: exists,
                sizeBytes: sizeBytes,
                error: error,
              ),
            );
          }
        }
      } on CancelledException {
        cancelled = true;
      } on FileSystemException catch (e) {
        controller.add(
          ScanEvent.discovering(
            message: 'File system access error: ${e.message}',
            currentPath: e.path,
          ),
        );
      } catch (e) {
        controller.add(ScanEvent.discovering(message: 'Scan failed: $e'));
      } finally {
        final finishedAt = DateTime.now().toUtc();
        controller.add(
          ScanEvent.done(
            ScanResult(
              startedAt: startedAt,
              finishedAt: finishedAt,
              profile: request.profile,
              cancelled: cancelled,
              projects: projects,
              xcodeTargets: xcodeTargets,
              globalTargets: globalTargets,
            ),
          ),
        );
        await controller.close();
      }
    }();

    return controller.stream;
  }
}

Future<List<TargetScanResult>> _scanXcodeTargets({
  required List<CacheTarget> xcodeTargets,
  required ScanRequest request,
  required CancellationToken token,
  required ExcludeMatcher exclude,
  required _OnEvent onEvent,
}) async {
  final derivedDataRootPath = resolveXcodeDerivedDataPath();
  if (derivedDataRootPath == null || derivedDataRootPath.isEmpty) {
    return const <TargetScanResult>[];
  }

  final derivedDataRoot = Directory(derivedDataRootPath);
  if (!await derivedDataRoot.exists()) {
    return const <TargetScanResult>[];
  }

  final results = <TargetScanResult>[];
  final target = xcodeTargets.first;
  Stream<FileSystemEntity> entries;
  try {
    entries = derivedDataRoot.list(followLinks: false);
  } on FileSystemException {
    return const <TargetScanResult>[];
  }

  try {
    await for (final entity in entries) {
      token.throwIfCancelled();
      if (entity is! Directory) {
        continue;
      }
      if (exclude.matches(entity.path)) {
        continue;
      }

      onEvent(
        ScanEvent.sizing(
          message: 'Sizing Xcode DerivedData: ${p.basename(entity.path)}',
          currentPath: entity.path,
        ),
      );

      final (exists, sizeBytes, error) = await _scanTarget(
        target: target,
        absolutePath: entity.path,
        computeSize: request.computeSizes,
        followSymlinks: request.followSymlinks,
        token: token,
        exclude: exclude,
      );

      final attribution = await attributeDerivedDataDirectory(entity);
      results.add(
        TargetScanResult(
          targetId: target.id,
          category: target.category,
          risk: target.risk,
          path: p.normalize(entity.path),
          exists: exists,
          sizeBytes: sizeBytes,
          attributionStatus: attribution.status,
          attributedProjectRootPath: attribution.projectRootPath,
          attributionConfidence: attribution.confidence,
          attributionEvidencePath: attribution.evidencePath,
          error: error,
        ),
      );
    }
  } on FileSystemException {
    // Ignore inaccessible DerivedData children and keep partial results.
  }

  results.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
  return results;
}

const _pruneDirNames = <String>{
  '.git',
  '.dart_tool',
  'build',
  'node_modules',
  '.idea',
  '.gradle',
  'Pods',
  'DerivedData',
  '.pub-cache',
  '.fvm',
};

typedef _OnProject = void Function(Directory projectRoot);
typedef _OnEvent = void Function(ScanEvent event);

Future<bool> _shouldTraversePath(
  String dirPath,
  _MelosWorkspace? workspace,
) async {
  if (!_hasPackagesSegment(dirPath)) {
    final resolvedPath = await _resolveSymlinkTargetPath(dirPath);
    if (resolvedPath == null || !_hasPackagesSegment(resolvedPath)) {
      return true;
    }
    return workspace?.allowsPackagesPath(resolvedPath) == true;
  }
  return workspace?.allowsPackagesPath(dirPath) == true;
}

Future<String?> _resolveSymlinkTargetPath(String path) async {
  final type = await FileSystemEntity.type(path, followLinks: false);
  if (type != FileSystemEntityType.link) {
    return null;
  }
  try {
    return p.normalize(Directory(path).resolveSymbolicLinksSync());
  } on FileSystemException {
    return null;
  }
}

bool _hasPackagesSegment(String path) {
  final normalized = path.trim().replaceAll('\\', '/');
  if (normalized.isEmpty) return false;
  return RegExp(
    r'(^|/)packages(/|$)',
    caseSensitive: !Platform.isWindows,
  ).hasMatch(normalized);
}

class _MelosWorkspace {
  const _MelosWorkspace({required this.packageRoots});

  final Set<String> packageRoots;

  bool allowsPackagesPath(String dirPath) {
    for (final packageRoot in packageRoots) {
      if (_pathHierarchyOverlaps(dirPath, packageRoot)) {
        return true;
      }
    }
    return false;
  }
}

class _MelosWorkspaceCache {
  final Map<String, Future<_MelosWorkspace?>> _workspaceByRootPath = {};
  final Map<String, Future<_MelosWorkspace?>> _workspaceByLookupPath = {};

  Future<_MelosWorkspace?> resolveForPath(String path) {
    final normalized = p.normalize(path);
    return _workspaceByLookupPath.putIfAbsent(normalized, () async {
      var current = Directory(normalized).absolute.path;
      while (true) {
        final workspace = await resolveAtPath(current);
        if (workspace != null) {
          return workspace;
        }
        final parent = Directory(current).parent.path;
        if (parent == current) {
          break;
        }
        current = parent;
      }
      return null;
    });
  }

  Future<_MelosWorkspace?> resolveAtPath(String path) {
    final normalized = p.normalize(path);
    return _workspaceByRootPath.putIfAbsent(
      normalized,
      () => _loadMelosWorkspaceAt(normalized),
    );
  }
}

Future<_MelosWorkspace?> _loadMelosWorkspaceAt(String workspaceRootPath) async {
  final melosFile = await _findMelosConfigFile(workspaceRootPath);
  if (melosFile == null) {
    return null;
  }

  try {
    final yamlText = await melosFile.readAsString();
    final decoded = loadYaml(yamlText);
    final yaml = decoded is YamlMap ? decoded : null;

    final rawPackagePatterns = _readYamlStringList(yaml?['packages']);
    final packagePatterns = rawPackagePatterns.isEmpty
        ? const <String>['packages/**']
        : rawPackagePatterns;
    final ignorePatterns = _readYamlStringList(yaml?['ignore']);

    final packageRoots = await _resolveMelosPackageRoots(
      workspaceRootPath: workspaceRootPath,
      patterns: packagePatterns,
    );
    if (ignorePatterns.isNotEmpty) {
      final ignoredPackageRoots = await _resolveMelosPackageRoots(
        workspaceRootPath: workspaceRootPath,
        patterns: ignorePatterns,
      );
      packageRoots.removeAll(ignoredPackageRoots);
    }
    return _MelosWorkspace(packageRoots: packageRoots);
  } on Exception {
    return null;
  }
}

Future<File?> _findMelosConfigFile(String rootPath) async {
  final yaml = File(p.join(rootPath, 'melos.yaml'));
  if (await yaml.exists()) {
    return yaml;
  }
  final yml = File(p.join(rootPath, 'melos.yml'));
  if (await yml.exists()) {
    return yml;
  }
  return null;
}

List<String> _readYamlStringList(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return raw
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

Future<Set<String>> _resolveMelosPackageRoots({
  required String workspaceRootPath,
  required List<String> patterns,
}) async {
  final packageRoots = <String>{};
  final root = Directory(workspaceRootPath).absolute.path;

  for (final pattern in patterns) {
    final globPattern = _toPubspecGlobPattern(pattern);
    Glob glob;
    try {
      glob = Glob(globPattern);
    } on FormatException {
      continue;
    }
    await for (final entry in glob.list(root: root, followLinks: false)) {
      if (entry is! File) {
        continue;
      }
      packageRoots.add(p.normalize(entry.parent.absolute.path));
    }
  }
  return packageRoots;
}

String _toPubspecGlobPattern(String pattern) {
  var normalized = pattern.trim().replaceAll('\\', '/');
  while (normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  if (normalized.isEmpty) {
    return 'pubspec.yaml';
  }
  if (normalized.endsWith('pubspec.yaml')) {
    return normalized;
  }
  return '$normalized/pubspec.yaml';
}

bool _pathHierarchyOverlaps(String left, String right) {
  return _isSameOrWithin(left, right) || _isSameOrWithin(right, left);
}

bool _isSameOrWithin(String path, String ancestor) {
  final normalizedPath = _normalizePathForComparison(path);
  final normalizedAncestor = _normalizePathForComparison(ancestor);
  if (normalizedPath == normalizedAncestor) {
    return true;
  }
  return p.isWithin(normalizedAncestor, normalizedPath);
}

String _normalizePathForComparison(String path) {
  final normalized = p.normalize(path);
  if (Platform.isWindows) {
    return normalized.toLowerCase();
  }
  return normalized;
}

Future<void> _discoverUnder(
  Directory dir, {
  required int depth,
  required ScanRequest request,
  required ExcludeMatcher exclude,
  required CancellationToken token,
  required _MelosWorkspace? workspace,
  required _MelosWorkspaceCache workspaceCache,
  required _OnProject onProject,
  required _OnEvent onEvent,
}) async {
  token.throwIfCancelled();

  final dirPath = p.normalize(dir.path);
  if (exclude.matches(dirPath)) return;
  final localWorkspace = await workspaceCache.resolveAtPath(dirPath);
  final activeWorkspace = localWorkspace ?? workspace;
  if (!await _shouldTraversePath(dirPath, activeWorkspace)) {
    return;
  }

  final base = p.basename(dirPath);
  if (_pruneDirNames.contains(base)) return;

  if (await _isFlutterProjectRoot(dirPath)) {
    onEvent(
      ScanEvent.discovering(
        message: 'Found Flutter project',
        currentPath: dirPath,
      ),
    );
    onProject(Directory(dirPath));
    return;
  }

  if (depth >= request.maxDepth) return;

  Stream<FileSystemEntity> entries;
  try {
    entries = dir.list(followLinks: request.followSymlinks);
  } on FileSystemException {
    return;
  }

  try {
    await for (final entity in entries) {
      token.throwIfCancelled();
      if (entity is! Directory) continue;
      await _discoverUnder(
        entity,
        depth: depth + 1,
        request: request,
        exclude: exclude,
        token: token,
        workspace: activeWorkspace,
        workspaceCache: workspaceCache,
        onProject: onProject,
        onEvent: onEvent,
      );
    }
  } on FileSystemException {
    return;
  }
}

Future<bool> _isFlutterProjectRoot(String dirPath) async {
  try {
    final pubspec = File(p.join(dirPath, 'pubspec.yaml'));
    if (!await pubspec.exists()) return false;

    final metadata = File(p.join(dirPath, '.metadata'));
    if (await metadata.exists()) return true;

    final iosDir = Directory(p.join(dirPath, 'ios'));
    if (await iosDir.exists()) return true;

    final androidDir = Directory(p.join(dirPath, 'android'));
    if (await androidDir.exists()) return true;

    return false;
  } on FileSystemException {
    return false;
  }
}

Future<String?> _readPubspecName(Directory projectRoot) async {
  final pubspec = File(p.join(projectRoot.path, 'pubspec.yaml'));
  if (!await pubspec.exists()) return null;
  try {
    final doc = loadYaml(await pubspec.readAsString());
    if (doc is! YamlMap) return null;
    final name = doc['name'];
    if (name is String && name.trim().isNotEmpty) {
      return name.trim();
    }
  } catch (_) {
    // ignore and fall back to folder name
  }
  return null;
}

Future<(bool exists, int sizeBytes, String? error)> _scanTarget({
  required CacheTarget target,
  required String absolutePath,
  required bool computeSize,
  required bool followSymlinks,
  required CancellationToken token,
  required ExcludeMatcher exclude,
}) async {
  try {
    final exists = await switch (target.kind) {
      CacheTargetKind.directory => Directory(absolutePath).exists(),
      CacheTargetKind.file => File(absolutePath).exists(),
    };

    if (!exists || !computeSize) {
      return (exists, 0, null);
    }

    final sizeBytes = await switch (target.kind) {
      CacheTargetKind.directory => _directorySize(
        Directory(absolutePath),
        followSymlinks: followSymlinks,
        token: token,
        exclude: exclude,
      ),
      CacheTargetKind.file => File(absolutePath).length(),
    };

    return (exists, sizeBytes, null);
  } on FileSystemException catch (e) {
    return (false, 0, e.message);
  }
}

Future<int> _directorySize(
  Directory dir, {
  required bool followSymlinks,
  required CancellationToken token,
  required ExcludeMatcher exclude,
}) async {
  var sum = 0;
  final stack = <Directory>[dir];

  while (stack.isNotEmpty) {
    token.throwIfCancelled();
    final current = stack.removeLast();
    if (exclude.matches(current.path)) {
      continue;
    }

    Stream<FileSystemEntity> entries;
    try {
      entries = current.list(followLinks: followSymlinks);
    } on FileSystemException {
      continue;
    }

    try {
      await for (final entity in entries) {
        token.throwIfCancelled();
        if (exclude.matches(entity.path)) continue;
        if (entity is Link && !followSymlinks) continue;
        if (entity is File) {
          try {
            sum += await entity.length();
          } on FileSystemException {
            // ignore unreadable file
          }
        } else if (entity is Directory) {
          stack.add(entity);
        }
      }
    } on FileSystemException {
      // ignore unreadable directory traversal errors
      continue;
    }
  }

  return sum;
}

Future<bool> _safeExistsDirectory(Directory directory) async {
  try {
    return await directory.exists();
  } on FileSystemException {
    return false;
  }
}
