extension type const AuthId(String value) {
  factory AuthId.fromJson(dynamic value) => AuthId(value);
  String toJson() => value;
}
