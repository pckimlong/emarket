import 'package:emarket_server/src/system/system_service.dart';
import 'package:serverpod/serverpod.dart';

class CustomerSystemEndpoint extends Endpoint {
  CustomerSystemEndpoint({SystemService? service})
    : service = service ?? SystemService();

  final SystemService service;
}
