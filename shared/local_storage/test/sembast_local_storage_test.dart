import 'package:local_storage/local_storage.dart';
import 'package:test/test.dart';

void main() {
  group('SembastLocalStorage', () {
    late ILocalStorage storage;

    setUp(() async {
      storage = await SembastLocalStorage.inMemory();
    });

    tearDown(() async {
      await storage.close();
    });

    test('supports standard key-value primitives', () async {
      // String
      await storage.setString('theme', 'dark');
      expect(await storage.getString('theme'), 'dark');
      expect(
        await storage.getString('non_existent', defaultValue: 'light'),
        'light',
      );

      // Bool
      await storage.setBool('is_authenticated', true);
      expect(await storage.getBool('is_authenticated'), true);
      expect(await storage.getBool('is_guest', defaultValue: false), false);

      // Int
      await storage.setInt('counter', 42);
      expect(await storage.getInt('counter'), 42);

      // Double
      await storage.setDouble('rating', 4.8);
      expect(await storage.getDouble('rating'), 4.8);

      // String List
      await storage.setStringList('tags', ['flutter', 'dart']);
      expect(await storage.getStringList('tags'), ['flutter', 'dart']);
    });

    test('supports JSON map and custom object encoders/decoders', () async {
      final userJson = {'id': 'user_1', 'name': 'John Doe'};
      await storage.setJson('current_user', userJson);

      expect(await storage.getJson('current_user'), userJson);

      // Custom decoder
      final user = await storage.get<_TestUser>(
        'current_user',
        decoder: _TestUser.fromJson,
      );
      expect(user?.id, 'user_1');
      expect(user?.name, 'John Doe');

      // Custom encoder
      final newUser = const _TestUser(id: 'user_2', name: 'Alice');
      await storage.set(
        'current_user',
        newUser,
        encoder: (u) => u.toJson(),
      );

      final fetchedUser = await storage.get<_TestUser>(
        'current_user',
        decoder: _TestUser.fromJson,
      );
      expect(fetchedUser?.name, 'Alice');
    });

    test('supports isolated named stores / namespaces', () async {
      await storage.setString('token', 'main_token');
      await storage.setString('token', 'auth_token', store: 'auth_store');

      expect(await storage.getString('token'), 'main_token');
      expect(
        await storage.getString('token', store: 'auth_store'),
        'auth_token',
      );

      // Clearing one store should not affect the other
      await storage.clear(store: 'auth_store');
      expect(await storage.getString('token'), 'main_token');
      expect(await storage.getString('token', store: 'auth_store'), isNull);
    });

    test(
      'supports key management (containsKey, remove, getKeys, getAll, clear)',
      () async {
        await storage.setString('k1', 'v1');
        await storage.setString('k2', 'v2');

        expect(await storage.containsKey('k1'), isTrue);
        expect(await storage.containsKey('k3'), isFalse);

        expect(await storage.getKeys(), {'k1', 'k2'});
        expect(await storage.getAll(), {'k1': 'v1', 'k2': 'v2'});

        await storage.remove('k1');
        expect(await storage.containsKey('k1'), isFalse);

        await storage.clear();
        expect(await storage.getKeys(), isEmpty);
      },
    );

    test('supports reactive watching via streams', () async {
      final stream = storage.watch<String>('status');

      expectLater(
        stream,
        emitsInOrder([isNull, 'idle', 'active', isNull]),
      );

      await storage.setString('status', 'idle');
      await storage.setString('status', 'active');
      await storage.remove('status');
    });
  });
}

class _TestUser {
  final String id;
  final String name;

  const _TestUser({required this.id, required this.name});

  factory _TestUser.fromJson(Map<String, dynamic> json) => _TestUser(
    id: json['id'] as String,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
