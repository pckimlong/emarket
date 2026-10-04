import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:emarket_client/emarket_client.dart' show CatalogDto;

import 'catalog_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<CatalogDto, Catalog>(
    fields: [
      Field('id', custom: CatalogMapper.dtoIdToDomainId),
    ],
  ),
])
class CatalogMapper extends $CatalogMapper {
  const CatalogMapper();

  static CatalogId dtoIdToDomainId(CatalogDto dto) {
    if (dto.id == null) {
      throw StateError('Cannot map an unpersisted CatalogDto to Catalog.');
    }
    return CatalogId(dto.id!.uuid);
  }
}
