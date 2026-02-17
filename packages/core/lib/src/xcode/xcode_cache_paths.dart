import 'dart:io';

import 'package:path/path.dart' as p;

/// Target id for Xcode DerivedData.
const String xcodeDerivedDataTargetId = 'xcode.derived_data';

/// Resolves Xcode DerivedData path on macOS.
///
/// Returns `null` for non-macOS platforms.
String? resolveXcodeDerivedDataPath({
  Map<String, String>? environment,
  String? operatingSystem,
}) {
  final os = operatingSystem ?? Platform.operatingSystem;
  if (os != 'macos') return null;

  final env = environment ?? Platform.environment;
  final home = _homeDir(env);
  return p.normalize(
    p.join(home, 'Library', 'Developer', 'Xcode', 'DerivedData'),
  );
}

String _homeDir(Map<String, String> env) {
  final home = env['HOME'];
  if (home != null && home.isNotEmpty) {
    return p.normalize(home);
  }
  return p.normalize(Directory.current.path);
}
