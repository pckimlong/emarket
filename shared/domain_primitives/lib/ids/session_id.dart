extension type const SessionId(String value) {
  factory SessionId.fromJson(dynamic value) => SessionId(value);
  String toJson() => value;
}
