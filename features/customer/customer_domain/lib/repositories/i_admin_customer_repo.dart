import 'package:customer_domain/customer_domain.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

abstract class IAdminCustomerRepo {
  Result<IList<Customer>> listCustomers();
}
