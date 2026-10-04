import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:emarket_client/emarket_client.dart'
    show ShopContextDto, ShopDto;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:shop_domain/shop_domain.dart';

import 'shop_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<ShopDto, Shop>(
    fields: [
      Field('id', custom: ShopMapper.dtoIdToDomainId),
    ],
  ),
])
class ShopMapper extends $ShopMapper {
  const ShopMapper();

  static ShopId dtoIdToDomainId(ShopDto dto) {
    if (dto.id == null) {
      throw StateError(
        'Cannot map an unpersisted ShopDto to Shop.',
      );
    }
    return ShopId(dto.id!.uuid);
  }

  ActiveShopContext toActiveShopContext(ShopContextDto dto) {
    return ActiveShopContext(
      shopId: ShopId(dto.shopId.uuid),
      shopName: dto.shopName,
      role: dto.role,
      permissions: dto.permissions.toIList(),
    );
  }
}
