import 'package:domain_primitives/domain_primitives.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog.freezed.dart';

@freezed
abstract class Catalog with _$Catalog {
  const factory Catalog({
    required CatalogId id,
  }) = _Catalog;
}
