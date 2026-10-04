import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:emarket_client/emarket_client.dart' show {{class_name}}Dto;
import 'package:{{feature_name}}_domain/{{feature_name}}_domain.dart';

import '{{feature_name}}_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<{{class_name}}Dto, {{class_name}}>(
    fields: [
      Field('id', custom: {{class_name}}Mapper.dtoIdToDomainId),
    ],
  ),
])
class {{class_name}}Mapper extends ${{class_name}}Mapper {
  const {{class_name}}Mapper();

  static {{class_name}}Id dtoIdToDomainId({{class_name}}Dto dto) {
    if (dto.id == null) {
      throw StateError(
        'Cannot map an unpersisted {{class_name}}Dto to {{class_name}}.',
      );
    }
    return {{class_name}}Id(dto.id!.uuid);
  }
}
