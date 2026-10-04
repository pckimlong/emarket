import 'package:emarket_server/src/shop/shop_service.dart';
import 'package:serverpod/serverpod.dart';

class CustomerShopEndpoint extends Endpoint {
  CustomerShopEndpoint({ShopService? service})
    : service = service ?? ShopService();

  final ShopService service;
}
