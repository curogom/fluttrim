enum AttributionStatus { none, attributed, unknown }

extension AttributionStatusJson on AttributionStatus {
  String toJsonValue() => name;

  static AttributionStatus fromJsonValue(String value) =>
      AttributionStatus.values.byName(value);
}
