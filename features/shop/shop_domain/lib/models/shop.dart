import 'package:domain_primitives/domain_primitives.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop.freezed.dart';

@freezed
abstract class Shop with _$Shop {
  const factory Shop({
    required ShopId id,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Shop;
}
