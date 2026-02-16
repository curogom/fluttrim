import 'cache_category.dart';
import 'profile.dart';
import 'risk.dart';

enum CacheTargetKind { directory, file }

class CacheTarget {
  const CacheTarget({
    required this.id,
    required this.category,
    required this.kind,
    required this.minProfile,
    required this.risk,
    required this.rationale,
    this.projectRelativePath,
  });

  final String id;
  final CacheCategory category;
  final CacheTargetKind kind;
  final Profile minProfile;
  final Risk risk;
  final String rationale;

  // For CacheCategory.project targets only.
  final String? projectRelativePath;

  bool isIncludedIn(Profile profile) => profile.index >= minProfile.index;

  Map<String, Object?> toJson() => {
    'id': id,
    'category': category.toJsonValue(),
    'kind': kind.name,
    'minProfile': minProfile.toJsonValue(),
    'risk': risk.toJsonValue(),
    'rationale': rationale,
    'projectRelativePath': projectRelativePath,
  };
}
