import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:emarket_client/emarket_client.dart' show ProductDto;

import 'product_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<ProductDto, Product>(
    fields: [
      Field('id', custom: ProductMapper.dtoIdToDomainId),
    ],
  ),
])
class ProductMapper extends $ProductMapper {
  const ProductMapper();

  static ProductId dtoIdToDomainId(ProductDto dto) {
    if (dto.id == null) {
      throw StateError('Cannot map an unpersisted ProductDto to Product.');
    }
    return ProductId(dto.id!.uuid);
  }
}
