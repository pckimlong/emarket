extension type const CustomerId(String value) {
  factory CustomerId.fromJson(dynamic value) => CustomerId(value);
  String toJson() => value;
}
