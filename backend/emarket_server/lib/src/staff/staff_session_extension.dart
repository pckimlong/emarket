import 'package:emarket_server/src/generated/protocol.dart';
import 'package:emarket_server/src/shared/auth/app_scopes.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

extension StaffSessionX on Session {
  /// In-memory check: Whether the session token includes the staff scope.
  bool get hasStaffScope =>
      authenticated?.scopes.contains(AppScopes.staff) ?? false;

  /// In-memory check: Whether the session token includes super admin scope.
  bool get hasAdminScope =>
      authenticated?.scopes.contains(AppScopes.admin) ?? false;

  /// Resolves the authenticated [StaffDto] for the current session.
  ///
  /// Throws [UnauthorizedException] if the session is not authenticated.
  /// Throws [NotFoundException] if no staff record is associated with the auth user.
  /// Throws [ForbiddenException] if the staff account has been deactivated.
  Future<StaffDto> getAuthenticatedStaff() async {
    final authInfo = authenticated;
    if (authInfo == null) {
      throw UnauthorizedException(message: 'Authentication required');
    }

    final staff = await StaffDto.db.findFirstRow(
      this,
      where: (r) => r.authUserId.equals(authInfo.authUserId),
    );

    if (staff == null) {
      throw NotFoundException(
        message: 'No staff profile associated with this account',
      );
    }

    if (!staff.isActive) {
      throw ForbiddenException(message: 'Staff account is deactivated');
    }

    return staff;
  }

  /// Returns the authenticated [StaffDto] or null if not authenticated or not found/active.
  Future<StaffDto?> getOptionalStaff() async {
    final authInfo = authenticated;
    if (authInfo == null) return null;

    final staff = await StaffDto.db.findFirstRow(
      this,
      where: (r) => r.authUserId.equals(authInfo.authUserId),
    );
    if (staff == null || !staff.isActive) return null;
    return staff;
  }

  /// Requires the authenticated user to be an active super administrator staff member.
  Future<StaffDto> requireAdminStaff() async {
    final staff = await getAuthenticatedStaff();
    if (!staff.isAdmin) {
      throw ForbiddenException(
        message: 'Administrator privileges required',
      );
    }
    return staff;
  }

  /// Ensures the authenticated staff has access to [shopId].
  /// Returns the [StaffDto] if authorized.
  /// Throws [ForbiddenException] if the staff is not an admin and not an active member of the shop.
  Future<StaffDto> requireShopAccess(UuidValue shopId) async {
    final staff = await getAuthenticatedStaff();
    if (staff.isAdmin) {
      return staff;
    }

    final membership = await ShopMemberDto.db.findFirstRow(
      this,
      where: (t) =>
          t.staffId.equals(staff.id!) &
          t.shopId.equals(shopId) &
          t.isActive.equals(true),
    );

    if (membership == null) {
      throw ForbiddenException(
        message: 'Staff member does not have access to this shop',
      );
    }

    return staff;
  }
}
