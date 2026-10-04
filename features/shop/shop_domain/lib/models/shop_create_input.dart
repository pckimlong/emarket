import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_create_input.freezed.dart';

@freezed
abstract class ShopCreateInput with _$ShopCreateInput {
  const ShopCreateInput._();

  const factory ShopCreateInput() = _ShopCreateInput;
}
