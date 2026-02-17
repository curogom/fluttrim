import 'profile.dart';

/// Scan input for [ScanService.scan].
class ScanRequest {
  /// Creates a scan request.
  const ScanRequest({
    required this.roots,
    this.profile = Profile.safe,
    this.includeGlobal = false,
    this.maxDepth = 5,
    this.exclusions = const [],
    this.computeSizes = true,
    this.followSymlinks = false,
  }) : assert(maxDepth >= 0);

  /// Root paths to discover Flutter projects from.
  final List<String> roots;

  /// Target profile controlling eligible cleanup categories.
  final Profile profile;

  /// Whether global caches (and Xcode on macOS) should be included.
  final bool includeGlobal;

  /// Maximum recursive discovery depth from each root.
  final int maxDepth;

  /// Paths/glob exclusions applied during discovery and sizing.
  final List<String> exclusions;

  /// Whether scan should compute byte sizes.
  final bool computeSizes;

  /// Whether filesystem traversal should follow symlinks.
  final bool followSymlinks;

  /// Serializes request payload as JSON.
  Map<String, Object?> toJson() => {
    'roots': roots,
    'profile': profile.toJsonValue(),
    'includeGlobal': includeGlobal,
    'maxDepth': maxDepth,
    'exclusions': exclusions,
    'computeSizes': computeSizes,
    'followSymlinks': followSymlinks,
  };
}
