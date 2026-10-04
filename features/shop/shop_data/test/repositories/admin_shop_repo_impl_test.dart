import 'package:emarket_client/emarket_client.dart';
import 'package:local_storage/local_storage.dart';
import 'package:shop_data/shop_data.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

final class FakeEndpointAdminShop extends Fake implements EndpointAdminShop {
  ShopContextDto? activeShopResult;
  UuidValue? lastPreferredShopIdReceived;
  List<ShopDto> accessibleShopsResult = [];
  Exception? errorToThrow;

  @override
  Future<ShopContextDto?> getActiveShop({UuidValue? preferredShopId}) async {
    if (errorToThrow != null) throw errorToThrow!;
    lastPreferredShopIdReceived = preferredShopId;
    return activeShopResult;
  }

  @override
  Future<List<ShopDto>> listAccessibleShops() async {
    if (errorToThrow != null) throw errorToThrow!;
    return accessibleShopsResult;
  }
}

void main() {
  late FakeEndpointAdminShop endpoint;
  late ILocalStorage localStorage;
  late AdminShopRepoImpl repo;

  final testShopUuid = UuidValue.fromString(
    '01920b72-2d14-7221-817c-c1db00000001',
  );
  final testShopDto = ShopDto(
    id: testShopUuid,
    name: 'Main Shop',
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
  final testShopContextDto = ShopContextDto(
    shopId: testShopUuid,
    shopName: 'Main Shop',
    role: 'owner',
    permissions: ['products.read', 'products.write'],
  );

  setUp(() async {
    endpoint = FakeEndpointAdminShop();
    localStorage = await SembastLocalStorage.inMemory();
    repo = AdminShopRepoImpl(
      endpoint: endpoint,
      localStorage: localStorage,
    );
  });

  group('AdminShopRepoImpl.getActiveShop', () {
    test('returns Some(ActiveShopContext) with role, permissions, shopName, and caches shopId when active shop is found', () async {
      endpoint.activeShopResult = testShopContextDto;

      final result = await repo.getActiveShop().run();

      expect(
        result.match(
          (failure) => null,
          (option) => option.match(
            () => null,
            (context) => context,
          ),
        ),
        isNotNull,
      );

      final context = result.toOption().toNullable()!.toNullable()!;
      expect(context.shopId.value, equals(testShopUuid.uuid));
      expect(context.shopName, equals('Main Shop'));
      expect(context.role, equals('owner'));
      expect(
        context.permissions.toList(),
        equals(['products.read', 'products.write']),
      );

      expect(
        await localStorage.getString('preferred_shop_id'),
        equals(testShopUuid.uuid),
      );
    });

    test(
      'uses cached preferred shop id when no explicit preference provided',
      () async {
        final cachedUuid = '01920b72-2d14-7221-817c-c1db00000002';
        await localStorage.setString('preferred_shop_id', cachedUuid);
        endpoint.activeShopResult = testShopContextDto;

        await repo.getActiveShop().run();

        expect(
          endpoint.lastPreferredShopIdReceived,
          equals(UuidValue.fromString(cachedUuid)),
        );
      },
    );

    test('prefers explicit preferredShopId over cached value', () async {
      await localStorage.setString(
        'preferred_shop_id',
        '01920b72-2d14-7221-817c-c1db00000002',
      );
      endpoint.activeShopResult = testShopContextDto;

      final explicitId = ShopId('01920b72-2d14-7221-817c-c1db00000003');
      await repo.getActiveShop(preferredShopId: explicitId).run();

      expect(
        endpoint.lastPreferredShopIdReceived,
        equals(UuidValue.fromString(explicitId.value)),
      );
    });

    test('returns None when endpoint returns null', () async {
      endpoint.activeShopResult = null;

      final result = await repo.getActiveShop().run();

      expect(
        result.match(
          (failure) => null,
          (option) => option.isNone(),
        ),
        isTrue,
      );
    });

    test('returns Left(Failure) when endpoint throws', () async {
      endpoint.errorToThrow = Exception('Network error');

      final result = await repo.getActiveShop().run();

      expect(result.isLeft(), isTrue);
    });
  });

  group('AdminShopRepoImpl.listAccessibleShops', () {
    test('returns list of domain shops', () async {
      endpoint.accessibleShopsResult = [testShopDto];

      final result = await repo.listAccessibleShops().run();

      expect(
        result.match(
          (failure) => null,
          (shops) => shops.map((s) => s.id.value).toList(),
        ),
        equals([testShopUuid.uuid]),
      );
    });
  });

  group('AdminShopRepoImpl.setActiveShop', () {
    test('calls getActiveShop with shopId, persists in local storage, and returns ActiveShopContext', () async {
      final shopId = ShopId(testShopUuid.uuid);
      endpoint.activeShopResult = testShopContextDto;

      final result = await repo.setActiveShop(shopId).run();

      expect(
        result.match(
          (failure) => null,
          (context) => context.shopId,
        ),
        equals(shopId),
      );

      expect(
        await localStorage.getString('preferred_shop_id'),
        equals(shopId.value),
      );
    });
  });
}
