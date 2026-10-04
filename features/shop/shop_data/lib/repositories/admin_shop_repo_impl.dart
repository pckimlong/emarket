import 'package:data_utils/data_utils.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:local_storage/i_local_storage.dart';
import 'package:shop_data/mappers/shop_mapper.dart';
import 'package:shop_domain/shop_domain.dart';

class AdminShopRepoImpl({
  required final EndpointAdminShop _endpoint,
  final ILocalStorage? _localStorage,
}) implements IAdminShopRepo {
  final _mapper = const ShopMapper();

  static const _preferredShopIdKey = 'preferred_shop_id';

  @override
  Result<IList<Shop>> listAccessibleShops() {
    return failureHandler(() async {
      final dtoList = await _endpoint.listAccessibleShops();
      return dtoList
          .map((dto) => _mapper.convert<ShopDto, Shop>(dto))
          .toIList();
    });
  }

  @override
  Result<Shop> createShop(ShopCreateInput input) {
    return failureHandler(() async {
      throw UnimplementedError();
    });
  }

  @override
  Result<Unit> deleteShop(ShopId shopId) {
    return failureHandler(() async {
      throw UnimplementedError();
    });
  }

  @override
  Result<Option<ActiveShopContext>> getActiveShop({
    ShopId? preferredShopId,
  }) {
    return failureHandler(() async {
      final effectiveShopId =
          preferredShopId ??
          await _localStorage
              ?.getString(_preferredShopIdKey)
              .then((value) => value != null ? ShopId(value) : null);

      final shopContextDto = await _endpoint.getActiveShop(
        preferredShopId: effectiveShopId != null
            ? UuidValue.fromString(effectiveShopId.value)
            : null,
      );

      if (shopContextDto == null) {
        return const None();
      }

      await _localStorage?.setString(
        _preferredShopIdKey,
        shopContextDto.shopId.uuid,
      );
      return Some(_mapper.toActiveShopContext(shopContextDto));
    });
  }

  @override
  Result<ActiveShopContext> setActiveShop(ShopId shopId) {
    return failureHandler(() async {
      final shopContextDto = await _endpoint.getActiveShop(
        preferredShopId: UuidValue.fromString(shopId.value),
      );

      if (shopContextDto == null) {
        throw StateError(
          'Shop ${shopId.value} is not accessible or not found.',
        );
      }

      await _localStorage?.setString(_preferredShopIdKey, shopId.value);
      return _mapper.toActiveShopContext(shopContextDto);
    });
  }

  @override
  Result<Shop> updateShop(
    ShopId shopId,
    ShopUpdateInput input,
  ) {
    return failureHandler(() async {
      throw UnimplementedError();
    });
  }
}
