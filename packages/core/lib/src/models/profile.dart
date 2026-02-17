/// Cleanup aggressiveness profile.
enum Profile { safe, medium, aggressive }

/// Parses profile name serialized by [ProfileJson.toJsonValue].
Profile profileFromJsonValue(String value) => Profile.values.byName(value);

/// JSON helpers for [Profile].
extension ProfileJson on Profile {
  /// Serializes enum value as a stable lowercase string.
  String toJsonValue() => name;
}
