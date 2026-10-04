extension type const CatalogId(String value) {
  factory CatalogId.fromJson(dynamic value) => CatalogId(value);
  String toJson() => value;
}
