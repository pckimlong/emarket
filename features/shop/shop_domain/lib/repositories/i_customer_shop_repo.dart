import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:shop_domain/shop_domain.dart';

abstract class ICustomerShopRepo {
  Result<IList<Shop>> listShops();
}
