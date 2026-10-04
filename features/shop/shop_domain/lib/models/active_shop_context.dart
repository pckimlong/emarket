import 'package:domain_primitives/ids/shop_id.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_shop_context.freezed.dart';

@freezed
abstract class ActiveShopContext with _$ActiveShopContext {
  const ActiveShopContext._();

  const factory ActiveShopContext({
    required ShopId shopId,
    required String shopName,
    required String role,
    @Default(IListConst([])) IList<String> permissions,
  }) = _ActiveShopContext;
}
