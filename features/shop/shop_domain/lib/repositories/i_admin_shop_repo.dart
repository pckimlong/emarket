import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shop_domain/shop_domain.dart';

abstract class IAdminShopRepo {
  /// Returns the active shop for the current user.
  ///
  /// Returns [None] when an active shop cannot be determined automatically
  /// and the user must select one.
  ///
  /// How the active shop is determined is an implementation detail. For example,
  /// an implementation may restore a previously selected shop, automatically
  /// select the only available shop, or use another valid persisted preference.
  ///
  /// Returns [Left] when the operation fails.
  Result<Option<ActiveShopContext>> getActiveShop({
    ShopId? preferredShopId,
  });

  /// Returns the shops the current user is allowed to access.
  Result<IList<Shop>> listAccessibleShops();
  Result<ActiveShopContext> setActiveShop(ShopId shopId);
  Result<Shop> createShop(ShopCreateInput input);
  Result<Shop> updateShop(ShopId shopId, ShopUpdateInput input);
  Result<Unit> deleteShop(ShopId shopId);
}
