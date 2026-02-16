enum Profile { safe, medium, aggressive }

Profile profileFromJsonValue(String value) => Profile.values.byName(value);

extension ProfileJson on Profile {
  String toJsonValue() => name;
}
