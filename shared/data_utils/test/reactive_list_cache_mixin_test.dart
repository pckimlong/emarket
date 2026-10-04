import 'dart:async';

import 'package:data_utils/data_utils.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:test/test.dart';

class TestItem {
  final String id;
  final String name;

  const TestItem(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}

class FakeRepo with ReactiveListCacheMixin<TestItem, String> {
  int fetchCount = 0;
  Completer<IList<TestItem>>? nextFetchCompleter;
  IList<TestItem> itemsToReturn = IList(const [
    TestItem('1', 'Apple'),
    TestItem('2', 'Banana'),
  ]);
  Exception? errorToThrow;

  @override
  String getItemId(TestItem item) => item.id;

  @override
  Future<IList<TestItem>> fetchRemoteItems() async {
    fetchCount++;
    if (nextFetchCompleter != null) {
      return nextFetchCompleter!.future;
    }
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return itemsToReturn;
  }
}

void main() {
  late FakeRepo repo;

  setUp(() {
    repo = FakeRepo();
  });

  tearDown(() {
    repo.disposeReactiveCache();
  });

  group('ReactiveListCacheMixin', () {
    test('initial subscription fetches from remote and emits data', () async {
      expect(repo.hasCachedItems, isFalse);

      final emission = await repo.watchCachedList().first;

      expect(emission, equals(repo.itemsToReturn));
      expect(repo.hasCachedItems, isTrue);
      expect(repo.cachedItems, equals(repo.itemsToReturn));
      expect(repo.fetchCount, equals(1));
    });

    test('re-subscribing immediately emits cached data and triggers background fetch (SWR)', () async {
      // 1. First subscription
      await repo.watchCachedList().first;
      expect(repo.fetchCount, equals(1));

      // 2. Prepare fresh items for background fetch
      repo.itemsToReturn = IList(const [
        TestItem('1', 'Apple Updated'),
        TestItem('2', 'Banana'),
        TestItem('3', 'Cherry'),
      ]);

      // 3. Second subscription receives cached data immediately, then updated data
      final emissions = <IList<TestItem>>[];
      final sub = repo.watchCachedList().listen(emissions.add);

      await pumpEventQueue();

      // First emission should be the cached stale data
      expect(emissions.first.length, equals(2));
      expect(emissions.first.first.name, equals('Apple'));

      await pumpEventQueue();

      // Second emission should be the fresh server data
      expect(emissions.last.length, equals(3));
      expect(emissions.last.first.name, equals('Apple Updated'));
      expect(repo.fetchCount, equals(2));

      await sub.cancel();
    });

    test(
      'deduplicates concurrent fetches (Thundering Herd protection)',
      () async {
        repo.nextFetchCompleter = Completer<IList<TestItem>>();

        // Subscribe twice simultaneously
        final future1 = repo.watchCachedList().first;
        final future2 = repo.watchCachedList().first;

        await pumpEventQueue();

        // Only 1 fetch call was made
        expect(repo.fetchCount, equals(1));

        // Resolve the fetch
        repo.nextFetchCompleter!.complete(repo.itemsToReturn);

        final result1 = await future1;
        final result2 = await future2;

        expect(result1, equals(repo.itemsToReturn));
        expect(result2, equals(repo.itemsToReturn));
        expect(repo.fetchCount, equals(1));
      },
    );

    test('addLocalItem appends to cached list', () async {
      await repo.watchCachedList().first;

      repo.addLocalItem(const TestItem('3', 'Cherry'));

      expect(repo.cachedItems?.length, equals(3));
      expect(repo.cachedItems?.last, equals(const TestItem('3', 'Cherry')));
    });

    test('updateLocalItem updates matching item by ID', () async {
      await repo.watchCachedList().first;

      repo.updateLocalItem(const TestItem('1', 'Honeycrisp Apple'));

      expect(repo.cachedItems?.first.name, equals('Honeycrisp Apple'));
    });

    test('removeLocalItem removes item by ID', () async {
      await repo.watchCachedList().first;

      repo.removeLocalItem('1');

      expect(repo.cachedItems?.length, equals(1));
      expect(repo.cachedItems?.first.id, equals('2'));
    });

    test('emits error on initial fetch failure when cache is empty', () async {
      repo.errorToThrow = Exception('Network down');

      expect(
        () => repo.watchCachedList().first,
        throwsA(isA<Failure>()),
      );
    });

    test(
      'preserves cached data when subsequent background sync fails',
      () async {
        // 1. Succeed first
        await repo.watchCachedList().first;

        // 2. Fail on second
        repo.errorToThrow = Exception('Network down');

        final emissions = <IList<TestItem>>[];
        final sub = repo.watchCachedList().listen(
          emissions.add,
          onError: (e) =>
              fail('Should not emit error when stale data is cached'),
        );

        await pumpEventQueue();

        // Cached data was emitted
        expect(emissions.length, equals(1));
        expect(emissions.first, equals(repo.itemsToReturn));

        await sub.cancel();
      },
    );
  });
}
