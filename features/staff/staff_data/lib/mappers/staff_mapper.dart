import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:emarket_client/emarket_client.dart' show StaffDto;
import 'package:staff_domain/staff_domain.dart';

import 'staff_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<StaffDto, Staff>(
    fields: [
      Field('id', custom: StaffMapper.dtoIdToDomainId),
      Field('authUserId', custom: StaffMapper.dtoAuthUserIdToDomainId),
    ],
  ),
])
class StaffMapper extends $StaffMapper {
  const StaffMapper();

  static StaffId dtoIdToDomainId(StaffDto dto) {
    if (dto.id == null) {
      throw StateError(
        'Cannot map an unpersisted StaffDto to Staff.',
      );
    }
    return StaffId(dto.id!.uuid);
  }

  static AuthId dtoAuthUserIdToDomainId(StaffDto dto) {
    if (dto.id == null) {
      throw StateError(
        'Cannot map an unpersisted StaffDto to Staff.',
      );
    }
    return AuthId(dto.id!.uuid);
  }
}
