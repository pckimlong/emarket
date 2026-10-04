import 'package:catalog_domain/catalog_domain.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

abstract class ICustomerBrandRepo {
  Result<IList<Brand>> listActiveBrands();
}
