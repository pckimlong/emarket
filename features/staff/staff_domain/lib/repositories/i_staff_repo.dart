import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:staff_domain/staff_domain.dart';

abstract class IStaffRepo {
  Result<IList<Staff>> listStaffs();
  Result<Staff> getCurrentStaff();
}
