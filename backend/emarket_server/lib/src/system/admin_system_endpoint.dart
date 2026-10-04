import 'package:emarket_server/src/system/system_service.dart';
import 'package:serverpod/serverpod.dart';

class AdminSystemEndpoint extends Endpoint {
  AdminSystemEndpoint({SystemService? service})
    : service = service ?? SystemService();

  final SystemService service;
}
