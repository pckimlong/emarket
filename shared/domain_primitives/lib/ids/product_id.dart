extension type const ProductId(String value) {
  factory ProductId.fromJson(dynamic value) => ProductId(value);
  String toJson() => value;
}
