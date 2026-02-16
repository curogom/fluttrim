enum Risk { low, medium, high }

extension RiskJson on Risk {
  String toJsonValue() => name;

  static Risk fromJsonValue(String value) => Risk.values.byName(value);
}
