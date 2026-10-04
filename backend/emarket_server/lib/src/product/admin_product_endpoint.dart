import 'package:emarket_server/src/product/product_service.dart';
import 'package:serverpod/serverpod.dart';

class AdminProductEndpoint extends Endpoint {
  AdminProductEndpoint({ProductService? service})
    : service = service ?? ProductService();

  final ProductService service;
}
