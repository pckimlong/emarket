import 'package:emarket_server/src/staff/staff_service.dart';
import 'package:serverpod/serverpod.dart';

class CustomerStaffEndpoint extends Endpoint {
  CustomerStaffEndpoint({StaffService? service})
    : service = service ?? StaffService();

  final StaffService service;
}
