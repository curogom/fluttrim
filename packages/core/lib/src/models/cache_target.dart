import 'cache_category.dart';
import 'profile.dart';
import 'risk.dart';

/// Filesystem shape of a cleanup target.
enum CacheTargetKind { directory, file }

/// Declarative definition for a cleanup target.
class CacheTarget {
  /// Creates a target definition.
  const CacheTarget({
    required this.id,
    required this.category,
    required this.kind,
    required this.minProfile,
    required this.risk,
    required this.rationale,
    this.projectRelativePath,
  });

  /// Stable target identifier used in logs/plans.
  final String id;

  /// Logical domain where this target belongs.
  final CacheCategory category;

  /// Expected filesystem entity type.
  final CacheTargetKind kind;

  /// Minimum profile where this target becomes eligible.
  final Profile minProfile;

  /// Risk level shown to users during preview.
  final Risk risk;

  /// Human-readable reason shown in UI/CLI.
  final String rationale;

  /// Relative path from project root for [CacheCategory.project] targets.
  final String? projectRelativePath;

  /// Returns `true` when [profile] includes this target.
  bool isIncludedIn(Profile profile) => profile.index >= minProfile.index;

  /// Serializes this target as JSON.
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
