import 'package:customer_data/mappers/customer_mapper.dart';
import 'package:customer_domain/customer_domain.dart';
import 'package:data_utils/data_utils.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

class AdminCustomerRepoImpl({
  required EndpointAdminCustomer endpoint,
}) implements IAdminCustomerRepo {
  final CustomerMapper mapper = const CustomerMapper();

  @override
  Result<IList<Customer>> listCustomers() {
    return failureHandler(() async {
      throw UnimplementedError();
    });
  }
}
