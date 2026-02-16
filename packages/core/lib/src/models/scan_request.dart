import 'profile.dart';

class ScanRequest {
  const ScanRequest({
    required this.roots,
    this.profile = Profile.safe,
    this.includeGlobal = false,
    this.maxDepth = 5,
    this.exclusions = const [],
    this.computeSizes = true,
    this.followSymlinks = false,
  }) : assert(maxDepth >= 0);

  final List<String> roots;
  final Profile profile;
  final bool includeGlobal;
  final int maxDepth;
  final List<String> exclusions;
  final bool computeSizes;
  final bool followSymlinks;

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
