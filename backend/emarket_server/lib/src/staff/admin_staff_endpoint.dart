import 'package:emarket_server/src/generated/protocol.dart';
import 'package:emarket_server/src/shared/auth/app_scopes.dart';
import 'package:emarket_server/src/staff/staff_service.dart';
import 'package:emarket_server/src/staff/staff_session_extension.dart';
import 'package:serverpod/serverpod.dart';

class AdminStaffEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {AppScopes.staff};

  AdminStaffEndpoint({StaffService? service})
    : service = service ?? StaffService();

  final StaffService service;

  Future<StaffDto> getCurrentStaff(Session session) async {
    return session.getAuthenticatedStaff();
  }
}
