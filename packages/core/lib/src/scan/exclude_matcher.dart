import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

class ExcludeMatcher {
  ExcludeMatcher(List<String> patterns) {
    for (final raw in patterns) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;

      final posixPattern = _toPosix(trimmed);
      if (_looksAbsolute(posixPattern)) {
        _absolutePrefixes.add(
          _stripTrailingSlash(p.posix.normalize(posixPattern)),
        );
        continue;
      }

      final hasSep = posixPattern.contains('/');
      final hasWildcard = _hasWildcard(posixPattern);
      if (!hasSep && !hasWildcard) {
        _segmentNames.add(posixPattern);
        continue;
      }

      final normalizedGlob = hasSep ? posixPattern : '**/$posixPattern';
      _globs.add(Glob(normalizedGlob, context: p.posix));
    }
  }

  final Set<String> _segmentNames = {};
  final List<Glob> _globs = [];
  final List<String> _absolutePrefixes = [];

  bool matches(String path) {
    final posixPath = _toPosix(p.normalize(path));

    for (final prefix in _absolutePrefixes) {
      if (posixPath == prefix || posixPath.startsWith('$prefix/')) {
        return true;
      }
    }

    final segments = posixPath.split('/');
    for (final seg in segments) {
      if (_segmentNames.contains(seg)) return true;
    }

    for (final glob in _globs) {
      if (glob.matches(posixPath)) return true;
      if (glob.matches(p.posix.basename(posixPath))) return true;
    }

    return false;
  }
}

bool _looksAbsolute(String posixPath) {
  if (posixPath.startsWith('/')) return true;
  return RegExp(r'^[a-zA-Z]:/').hasMatch(posixPath);
}

bool _hasWildcard(String s) =>
    s.contains('*') || s.contains('?') || s.contains('[') || s.contains('{');

String _toPosix(String path) => path.replaceAll('\\', '/');

String _stripTrailingSlash(String s) {
  var out = s;
  while (out.endsWith('/')) {
    out = out.substring(0, out.length - 1);
  }
  return out;
}
