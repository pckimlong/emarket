import 'package:data_utils/data_utils.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:staff_data/mappers/staff_mapper.dart';
import 'package:staff_domain/staff_domain.dart';

class StaffRepoImpl({
  required final EndpointAdminStaff _endpoint,
}) implements IStaffRepo {
  final StaffMapper _mapper = const StaffMapper();

  @override
  Result<IList<Staff>> listStaffs() {
    return failureHandler(() async {
      throw UnimplementedError();
    });
  }

  @override
  Result<Staff> getCurrentStaff() {
    return failureHandler(() async {
      final result = await _endpoint.getCurrentStaff();
      return _mapper.convert(result);
    });
  }
}
