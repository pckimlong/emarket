import 'package:emarket_server/src/cart/cart_service.dart';
import 'package:serverpod/serverpod.dart';

class AdminCartEndpoint extends Endpoint {
  AdminCartEndpoint({CartService? service})
    : service = service ?? CartService();

  final CartService service;
}
