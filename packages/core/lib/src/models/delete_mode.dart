enum DeleteMode { trash, permanent }

extension DeleteModeJson on DeleteMode {
  String toJsonValue() => name;

  static DeleteMode fromJsonValue(String value) =>
      DeleteMode.values.byName(value);
}
