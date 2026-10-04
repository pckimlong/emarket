import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:emarket_client/emarket_client.dart' show CustomerDto;
import 'package:customer_domain/customer_domain.dart';

import 'customer_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<CustomerDto, Customer>(
    fields: [
      Field('id', custom: CustomerMapper.dtoIdToDomainId),
      Field('name', custom: CustomerMapper.dtoToName),
    ],
  ),
])
class CustomerMapper extends $CustomerMapper {
  const CustomerMapper();

  static CustomerId dtoIdToDomainId(CustomerDto dto) {
    if (dto.id == null) {
      throw StateError(
        'Cannot map an unpersisted CustomerDto to Customer.',
      );
    }
    return CustomerId(dto.id!.uuid);
  }

  static String dtoToName(CustomerDto dto) {
    final parts = [
      dto.firstName,
      dto.lastName,
    ].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? (dto.email ?? 'Customer') : parts.join(' ');
  }
}
