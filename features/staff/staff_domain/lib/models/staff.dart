import 'package:domain_primitives/domain_primitives.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff.freezed.dart';

@freezed
abstract class Staff with _$Staff {
  const factory Staff({
    required StaffId id,
    required AuthId authUserId,
    required String firstName,
    required String? lastName,
    required bool isAdmin,
    required bool isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Staff;
}
