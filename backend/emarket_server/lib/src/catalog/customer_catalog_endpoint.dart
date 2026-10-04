import 'package:emarket_server/src/catalog/catalog_service.dart';
import 'package:serverpod/serverpod.dart';

class CustomerCatalogEndpoint extends Endpoint {
  CustomerCatalogEndpoint({CatalogService? service})
    : service = service ?? CatalogService();

  final CatalogService service;
}
