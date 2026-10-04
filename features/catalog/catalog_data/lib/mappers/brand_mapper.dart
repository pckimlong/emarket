import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:emarket_client/emarket_client.dart' show BrandDto;

import 'brand_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<BrandDto, Brand>(
    fields: [
      Field('id', custom: BrandMapper.dtoIdToDomainId),
      Field('logoUri', custom: BrandMapper.dtoLogoPathToUri),
    ],
  ),
])
class BrandMapper extends $BrandMapper {
  const BrandMapper({this.baseStorageUrl = 'http://localhost:8080'});

  final String baseStorageUrl;
  static String defaultStorageBaseUrl = 'http://localhost:8080';

  static BrandId dtoIdToDomainId(BrandDto dto) {
    if (dto.id == null) {
      throw StateError('Cannot map an unpersisted BrandDto to Brand.');
    }
    return BrandId(dto.id!.uuid);
  }

  static Uri dtoLogoPathToUri(BrandDto dto) {
    final path = dto.logoPath;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    final baseUri = Uri.parse(defaultStorageBaseUrl);
    return baseUri.replace(
      path: '/serverpod_cloud_storage',
      queryParameters: {
        'method': 'file',
        'path': path,
      },
    );
  }
}
