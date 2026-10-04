import 'package:emarket_server/src/order/order_service.dart';
import 'package:serverpod/serverpod.dart';

class AdminOrderEndpoint extends Endpoint {
  AdminOrderEndpoint({OrderService? service})
    : service = service ?? OrderService();

  final OrderService service;
}
