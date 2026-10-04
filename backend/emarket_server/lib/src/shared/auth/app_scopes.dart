import 'package:serverpod/serverpod.dart';

abstract final class AppScopes {
  /// Regular customer / buyer scope
  static const customer = Scope('customer');

  /// Staff member scope (store employee, manager, admin)
  static const staff = Scope('staff');

  /// Super administrator scope
  static const admin = Scope.admin;
}
