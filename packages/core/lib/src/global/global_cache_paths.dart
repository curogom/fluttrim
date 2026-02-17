import 'dart:io';

import 'package:path/path.dart' as p;

/// Target id for Dart/Flutter global pub cache.
const String globalPubCacheTargetId = 'global.pub_cache';

/// Target id for Gradle user-home cache.
const String globalGradleUserHomeTargetId = 'global.gradle_user_home';

/// Target id for CocoaPods cache directory.
const String globalCocoaPodsCacheTargetId = 'global.cocoapods_cache';

/// Target id for CocoaPods home directory.
const String globalCocoaPodsHomeTargetId = 'global.cocoapods_home';

/// Resolved absolute path for one global cache target id.
class GlobalCachePath {
  /// Creates a global cache path entry.
  const GlobalCachePath({required this.targetId, required this.path});

  /// Stable target identifier.
  final String targetId;

  /// Absolute filesystem path for the target.
  final String path;
}

/// Resolves OS-specific global cache paths.
List<GlobalCachePath> resolveGlobalCachePaths({
  Map<String, String>? environment,
  String? operatingSystem,
}) {
  final os = operatingSystem ?? Platform.operatingSystem;
  final env = environment ?? Platform.environment;
  final home = _homeDir(env, os);

  final paths = <GlobalCachePath>[
    GlobalCachePath(
      targetId: globalPubCacheTargetId,
      path: _pubCachePath(env, os, home),
    ),
    GlobalCachePath(
      targetId: globalGradleUserHomeTargetId,
      path: _gradleUserHomePath(env, home),
    ),
  ];

  if (os == 'macos') {
    paths.add(
      GlobalCachePath(
        targetId: globalCocoaPodsCacheTargetId,
        path: p.normalize(p.join(home, 'Library', 'Caches', 'CocoaPods')),
      ),
    );
    paths.add(
      GlobalCachePath(
        targetId: globalCocoaPodsHomeTargetId,
        path: p.normalize(p.join(home, '.cocoapods')),
      ),
    );
  } else if (os == 'linux') {
    paths.add(
      GlobalCachePath(
        targetId: globalCocoaPodsHomeTargetId,
        path: p.normalize(p.join(home, '.cocoapods')),
      ),
    );
  }

  return paths;
}

/// Resolves a single global cache path by [targetId].
String? resolveGlobalCachePathByTargetId(
  String targetId, {
  Map<String, String>? environment,
  String? operatingSystem,
}) {
  final paths = resolveGlobalCachePaths(
    environment: environment,
    operatingSystem: operatingSystem,
  );
  for (final item in paths) {
    if (item.targetId == targetId) {
      return item.path;
    }
  }
  return null;
}

String _pubCachePath(Map<String, String> env, String os, String home) {
  final explicit = env['PUB_CACHE'];
  if (explicit != null && explicit.isNotEmpty) {
    return p.normalize(explicit);
  }

  if (os == 'windows') {
    final localAppData = env['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return p.normalize(p.join(localAppData, 'Pub', 'Cache'));
    }
  }

  return p.normalize(p.join(home, '.pub-cache'));
}

String _gradleUserHomePath(Map<String, String> env, String home) {
  final explicit = env['GRADLE_USER_HOME'];
  if (explicit != null && explicit.isNotEmpty) {
    return p.normalize(explicit);
  }
  return p.normalize(p.join(home, '.gradle'));
}

String _homeDir(Map<String, String> env, String os) {
  if (os == 'windows') {
    final userProfile = env['USERPROFILE'];
    if (userProfile != null && userProfile.isNotEmpty) {
      return p.normalize(userProfile);
    }
  }
  final home = env['HOME'];
  if (home != null && home.isNotEmpty) {
    return p.normalize(home);
  }
  return p.normalize(Directory.current.path);
}
