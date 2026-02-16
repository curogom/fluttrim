enum CacheCategory { project, xcode, fvm, global }

extension CacheCategoryJson on CacheCategory {
  String toJsonValue() => name;

  static CacheCategory fromJsonValue(String value) =>
      CacheCategory.values.byName(value);
}
