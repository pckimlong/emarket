import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_update_input.freezed.dart';

@freezed
abstract class ShopUpdateInput with _$ShopUpdateInput {
  const ShopUpdateInput._();

  const factory ShopUpdateInput() = _ShopUpdateInput;
}
