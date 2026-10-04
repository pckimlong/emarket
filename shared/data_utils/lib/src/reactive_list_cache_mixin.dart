import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:rxdart/rxdart.dart';

import 'disposable.dart';
import 'failure_handler.dart';

/// A mixin providing Stale-While-Revalidate (SWR) caching with in-memory
/// CRUD synchronization for single-entity list repository implementations.
///
/// Subscribing to [watchCachedList] will:
/// 1. Immediately emit any existing cached items synchronously (0ms latency).
/// 2. Always trigger a background fetch via [fetchRemoteItems] to revalidate from the server.
/// 3. Automatically deduplicate in-flight server requests to protect against Thundering Herd.
/// 4. Emit fresh items to all active subscribers once the server responds.
///
/// ### Intended Scope & Limitations:
///
/// * **Use Only for Stable Master / Reference Data**:
///   This mixin is designed specifically for bounded master datasets (e.g. Brands,
///   Categories, Shop Settings, Roles) where the full list is fetched once and cached
///   in memory as a single source of truth.
///
/// * **Do NOT Use for Dynamic Server-Side Filtered or Paginated Data**:
///   Do not use this mixin for endpoints that require server-side pagination, search
///   keywords, date ranges, or dynamic query filters (e.g. Products catalog, Orders,
///   Audit logs). Storing server-filtered subsets in a single shared cache causes race
///   conditions and conflicts between multiple subscribers.
///   * If you need filtering on master data (e.g. `isActive`), fetch the complete list
///     here and filter locally in the BLoC/UI layer.
///   * For large paginated datasets, use one-shot `Result<PaginatedList<T>>` queries
///     managed directly by your BLoC instead.
///
/// ### Important Implementing Guidelines:
///
/// #### 1. In-Memory CRUD Synchronization
/// To keep the reactive stream updated in real time without requiring full server
/// re-fetches, you **must** call the local cache helper methods inside your mutation
/// commands (`create`, `update`, `delete`):
/// * Call [addLocalItem] after creating an entity.
/// * Call [updateLocalItem] after updating an entity.
/// * Call [removeLocalItem] after deleting an entity.
///
/// #### 2. Resource Disposal
/// Because this mixin allocates an in-memory [BehaviorSubject], you **must** expose
/// a `dispose()` method on your concrete repository implementation that invokes
/// [disposeReactiveCache] to prevent memory leaks when the repository or DI provider
/// unmounts.
///
/// ### Example Implementation:
/// ```dart
/// class AdminBrandRepoImpl with ReactiveListCacheMixin<Brand, BrandId> implements IAdminBrandRepo {
///   AdminBrandRepoImpl({required EndpointAdminBrand endpoint}) : _endpoint = endpoint;
///
///   final EndpointAdminBrand _endpoint;
///   final _mapper = const BrandMapper();
///
///   @override
///   BrandId getItemId(Brand item) => item.id;
///
///   @override
///   Future<IList<Brand>> fetchRemoteItems() async {
///     final dtoList = await _endpoint.listBrands(isActive: null);
///     return _mapper.convertIList<BrandDto, Brand>(dtoList);
///   }
///
///   @override
///   Stream<IList<Brand>> watchBrands() => watchCachedList();
///
///   @override
///   Result<Brand> createBrand(BrandInput input) {
///     return failureHandler(() async {
///       final dto = ...;
///       final result = await _endpoint.createBrand(dto);
///       final newBrand = _mapper.convert<BrandDto, Brand>(result);
///
///       // 🟢 Do not forget: sync newly created entity to in-memory cache!
///       addLocalItem(newBrand);
///
///       return newBrand;
///     });
///   }
///
///   @override
///   Result<Brand> updateBrand(BrandId brandId, BrandInput input) {
///     return failureHandler(() async {
///       final dto = ...;
///       final result = await _endpoint.updateBrand(dto);
///       final updatedBrand = _mapper.convert<BrandDto, Brand>(result);
///
///       // 🟢 Do not forget: sync updated entity to in-memory cache!
///       updateLocalItem(updatedBrand, brandId);
///
///       return updatedBrand;
///     });
///   }
///
///   @override
///   Result<Unit> deleteBrand(BrandId brandId) {
///     return failureHandler(() async {
///       await _endpoint.deleteBrand(brandId.value.toUuidValue());
///
///       // 🟢 Do not forget: remove deleted entity from in-memory cache!
///       removeLocalItem(brandId);
///
///       return unit;
///     });
///   }
///
///   // 🟢 Do not forget: release resources on disposal!
///   void dispose() => disposeReactiveCache();
/// }
/// ```
mixin ReactiveListCacheMixin<T, ID> implements Disposable {
  final _subject = BehaviorSubject<IList<T>>();
  Future<void>? _inFlightSync;

  /// Returns the unique identifier for the given entity [item].
  ID getItemId(T item);

  /// Fetches the latest list of items from the remote data source.
  Future<IList<T>> fetchRemoteItems();

  /// Whether the cache currently holds loaded items.
  bool get hasCachedItems => _subject.hasValue;

  /// The current cached items, or `null` if not yet loaded.
  IList<T>? get cachedItems => _subject.valueOrNull;

  /// Returns a reactive stream of the cached items following the
  /// Stale-While-Revalidate pattern.
  ///
  /// Replays existing cached items synchronously, while deduplicating in-flight
  /// server synchronizations in the background.
  Stream<IList<T>> watchCachedList() {
    return Rx.defer(() {
      _syncFromServer();
      return _subject.stream;
    });
  }

  /// Manually triggers a server synchronization, returning the shared in-flight future.
  Future<void> refreshCache() => _syncFromServer();

  Future<void> _syncFromServer() {
    return _inFlightSync ??= _performSync().whenComplete(() {
      _inFlightSync = null;
    });
  }

  Future<void> _performSync() async {
    final result = await failureHandler(fetchRemoteItems).run();

    result.fold(
      (failure) {
        // If the cache is empty, push the error so the UI can display an error state.
        // If stale data already exists, preserve it in the cache while logging/swallowing.
        if (!_subject.hasValue) {
          _subject.addError(failure);
        }
      },
      (freshItems) {
        _subject.add(freshItems);
      },
    );
  }

  /// Appends [item] to the local cache if the cache is currently initialized.
  ///
  /// Call this inside repository `create*` methods after the remote operation succeeds
  /// to notify all active stream subscribers immediately without a round-trip fetch.
  void addLocalItem(T item) {
    if (_subject.hasValue) {
      _subject.add(_subject.value.add(item));
    }
  }

  /// Updates an item in the local cache matching [explicitId] or `getItemId(updatedItem)`.
  ///
  /// Call this inside repository `update*` methods after the remote operation succeeds
  /// to replace the entity in memory and notify all active stream subscribers immediately.
  void updateLocalItem(T updatedItem, [ID? explicitId]) {
    if (_subject.hasValue) {
      final targetId = explicitId ?? getItemId(updatedItem);
      final updatedList = _subject.value
          .map((item) => getItemId(item) == targetId ? updatedItem : item)
          .toIList();
      _subject.add(updatedList);
    }
  }

  /// Removes the item with [id] from the local cache.
  ///
  /// Call this inside repository `delete*` methods after the remote operation succeeds
  /// to remove the entity from memory and notify all active stream subscribers immediately.
  void removeLocalItem(ID id) {
    if (_subject.hasValue) {
      final updatedList = _subject.value.removeWhere(
        (item) => getItemId(item) == id,
      );
      _subject.add(updatedList);
    }
  }

  /// Closes the underlying stream subject and cancels in-flight resources.
  ///
  /// **Must be called** when the repository implementation is disposed by the DI container.
  void disposeReactiveCache() {
    _subject.close();
  }

  @override
  void dispose() => disposeReactiveCache();
}
