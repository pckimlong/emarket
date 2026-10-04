import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../generated/protocol.dart';
import '../shared/auth/app_scopes.dart';

/// Creates the configured development admin and default shop once, without
/// exposing signup in the admin application. Existing accounts keep their
/// password or update it if configured.
Future<void> seedDefaultAdmin(Serverpod pod) async {
  if (pod.runMode != 'development') return;

  final email = Platform.environment['DEFAULT_ADMIN_EMAIL']?.trim();
  final password = Platform.environment['DEFAULT_ADMIN_PASSWORD'];
  final shopName =
      Platform.environment['DEFAULT_SHOP_NAME']?.trim() ?? 'Default Store';

  if (email == null && password == null) return;
  if (email == null || email.isEmpty || password == null || password.isEmpty) {
    throw StateError(
      'DEFAULT_ADMIN_EMAIL and DEFAULT_ADMIN_PASSWORD must both be set.',
    );
  }

  final session = await pod.createSession();
  try {
    final auth = AuthServices.instance;
    final existing = await auth.emailIdp.admin.findAccount(
      session,
      email: email,
    );

    if (existing != null) {
      // Ensure password is synchronized with configured password
      await auth.emailIdp.admin.setPassword(
        session,
        email: email,
        password: password,
      );
      await auth.authUsers.update(
        session,
        authUserId: existing.authUserId,
        scopes: {AppScopes.staff, AppScopes.admin},
      );

      var existingStaff = await StaffDto.db.findFirstRow(
        session,
        where: (t) =>
            t.email.equals(email) | t.authUserId.equals(existing.authUserId),
      );

      if (existingStaff == null) {
        existingStaff = await StaffDto.db.insertRow(
          session,
          StaffDto(
            authUserId: existing.authUserId,
            email: email,
            firstName: 'Super',
            lastName: 'Admin',
            isAdmin: true,
            isActive: true,
          ),
        );
        session.log('Created missing staff profile for default admin: $email');
      } else if (!existingStaff.isAdmin || !existingStaff.isActive) {
        existingStaff = await StaffDto.db.updateRow(
          session,
          existingStaff.copyWith(
            isAdmin: true,
            isActive: true,
          ),
        );
        session.log(
          'Updated staff profile for default admin to highest role: $email',
        );
      } else {
        session.log(
          'Default development admin and staff profile already exist: $email',
        );
      }

      await _ensureShopAndMembership(
        session,
        staff: existingStaff,
        shopName: shopName,
      );
      return;
    }

    await session.db.transaction((transaction) async {
      final user = await auth.authUsers.create(
        session,
        scopes: {AppScopes.staff, AppScopes.admin},
        transaction: transaction,
      );
      await auth.emailIdp.admin.createEmailAuthentication(
        session,
        authUserId: user.id,
        email: email,
        password: password,
        transaction: transaction,
      );
      await auth.userProfiles.createUserProfile(
        session,
        user.id,
        UserProfileData(
          email: email,
          fullName: 'Super Admin',
          userName: 'admin',
        ),
        transaction: transaction,
      );
      final staff = await StaffDto.db.insertRow(
        session,
        StaffDto(
          authUserId: user.id,
          email: email,
          firstName: 'Super',
          lastName: 'Admin',
          isAdmin: true,
          isActive: true,
        ),
        transaction: transaction,
      );

      await _ensureShopAndMembership(
        session,
        staff: staff,
        shopName: shopName,
        transaction: transaction,
      );
    });

    session.log(
      'Created default development admin with staff record & default shop: $email',
    );
  } finally {
    await session.close();
  }
}

Future<void> _ensureShopAndMembership(
  Session session, {
  required StaffDto staff,
  required String shopName,
  Transaction? transaction,
}) async {
  var shop = await ShopDto.db.findFirstRow(
    session,
    where: (t) => t.name.equals(shopName),
    transaction: transaction,
  );

  if (shop == null) {
    shop = await ShopDto.db.insertRow(
      session,
      ShopDto(
        name: shopName,
        description: 'Default development store',
        isActive: true,
      ),
      transaction: transaction,
    );
    session.log('Created default shop: $shopName');
  } else if (!shop.isActive) {
    shop = await ShopDto.db.updateRow(
      session,
      shop.copyWith(isActive: true),
      transaction: transaction,
    );
    session.log('Re-activated default shop: $shopName');
  }

  if (staff.id != null && shop.id != null) {
    final existingMembership = await ShopMemberDto.db.findFirstRow(
      session,
      where: (t) => t.staffId.equals(staff.id!) & t.shopId.equals(shop!.id!),
      transaction: transaction,
    );

    if (existingMembership == null) {
      await ShopMemberDto.db.insertRow(
        session,
        ShopMemberDto(
          staffId: staff.id!,
          shopId: shop.id!,
          role: 'owner',
          permissions: const ['*'],
          isActive: true,
        ),
        transaction: transaction,
      );
      session.log('Assigned admin staff to default shop ($shopName) as owner');
    } else if (!existingMembership.isActive) {
      await ShopMemberDto.db.updateRow(
        session,
        existingMembership.copyWith(
          isActive: true,
          role: 'owner',
          permissions: const ['*'],
        ),
        transaction: transaction,
      );
      session.log('Re-activated admin shop membership for: $shopName');
    }
  }
}
