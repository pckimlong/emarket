import 'package:emarket_server/src/customer/customer_service.dart';
import 'package:serverpod/serverpod.dart';

class AdminCustomerEndpoint extends Endpoint {
  AdminCustomerEndpoint({CustomerService? service})
    : service = service ?? CustomerService();

  final CustomerService service;
}
