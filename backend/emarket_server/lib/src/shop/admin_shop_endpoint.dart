import 'package:emarket_server/src/generated/protocol.dart';
import 'package:emarket_server/src/shared/auth/app_scopes.dart';
import 'package:emarket_server/src/shop/shop_service.dart';
import 'package:emarket_server/src/staff/staff_session_extension.dart';
import 'package:serverpod/serverpod.dart';

class AdminShopEndpoint extends Endpoint {
  AdminShopEndpoint({ShopService? service})
    : service = service ?? ShopService();

  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {AppScopes.staff};

  final ShopService service;

  Future<List<ShopDto>> listAccessibleShops(Session session) async {
    final staff = await session.getAuthenticatedStaff();

    if (staff.isAdmin) {
      return ShopDto.db.find(
        session,
        where: (t) => t.isActive.equals(true),
        orderBy: (t) => t.name,
      );
    }

    final memberships = await ShopMemberDto.db.find(
      session,
      where: (t) => t.staffId.equals(staff.id!) & t.isActive.equals(true),
    );

    if (memberships.isEmpty) {
      return [];
    }

    final shopIds = memberships.map((m) => m.shopId).toSet();
    return ShopDto.db.find(
      session,
      where: (t) => t.id.inSet(shopIds) & t.isActive.equals(true),
      orderBy: (t) => t.name,
    );
  }

  Future<ShopContextDto?> getActiveShop(
    Session session, {
    UuidValue? preferredShopId,
  }) async {
    final accessibleShops = await listAccessibleShops(session);
    if (accessibleShops.isEmpty) {
      return null;
    }

    final activeShop = switch (accessibleShops) {
      [final onlyShop] => onlyShop,
      _ when preferredShopId != null =>
        accessibleShops.where((s) => s.id == preferredShopId).firstOrNull,
      _ => null,
    };

    final activeShopId = activeShop?.id;
    if (activeShop == null || activeShopId == null) {
      return null;
    }

    final staff = await session.getAuthenticatedStaff();
    final membership = await ShopMemberDto.db.findFirstRow(
      session,
      where: (t) =>
          t.staffId.equals(staff.id!) &
          t.shopId.equals(activeShopId) &
          t.isActive.equals(true),
    );

    final String role;
    final List<String> permissions;

    if (membership != null) {
      role = membership.role;
      permissions = membership.permissions;
    } else if (staff.isAdmin) {
      role = 'admin';
      permissions = const ['*'];
    } else {
      return null;
    }

    return ShopContextDto(
      shopId: activeShopId,
      shopName: activeShop.name,
      role: role,
      permissions: permissions,
    );
  }
}
