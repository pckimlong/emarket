import 'package:emarket_server/src/order/order_service.dart';
import 'package:serverpod/serverpod.dart';

class CustomerOrderEndpoint extends Endpoint {
  CustomerOrderEndpoint({OrderService? service})
    : service = service ?? OrderService();

  final OrderService service;
}
