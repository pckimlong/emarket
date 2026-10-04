import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:emarket_client/emarket_client.dart' show CategoryDto;

import 'category_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<CategoryDto, Category>(
    fields: [
      Field('id', custom: CategoryMapper.dtoIdToDomainId),
    ],
  ),
])
class CategoryMapper extends $CategoryMapper {
  const CategoryMapper();

  static CategoryId dtoIdToDomainId(CategoryDto dto) {
    if (dto.id == null) {
      throw StateError('Cannot map an unpersisted CategoryDto to Category.');
    }
    return CategoryId(dto.id!.uuid);
  }
}
