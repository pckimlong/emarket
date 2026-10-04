import 'package:data_utils/data_utils.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:shop_data/mappers/shop_mapper.dart';
import 'package:shop_domain/shop_domain.dart';

class CustomerShopRepoImpl({
  required EndpointCustomerShop endpoint,
}) implements ICustomerShopRepo {
  final ShopMapper mapper = const ShopMapper();

  @override
  Result<IList<Shop>> listShops() {
    return failureHandler(() async {
      throw UnimplementedError();
    });
  }
}
