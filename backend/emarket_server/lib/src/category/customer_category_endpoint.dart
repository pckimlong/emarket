import 'package:emarket_server/src/category/category_service.dart';
import 'package:serverpod/serverpod.dart';

class CustomerCategoryEndpoint extends Endpoint {
  CustomerCategoryEndpoint({CategoryService? service})
    : service = service ?? CategoryService();

  final CategoryService service;
}
