import 'package:emarket_server/src/product/product_service.dart';
import 'package:serverpod/serverpod.dart';

class CustomerProductEndpoint extends Endpoint {
  CustomerProductEndpoint({ProductService? service})
    : service = service ?? ProductService();

  final ProductService service;
}
