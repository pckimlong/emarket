import 'dart:async';

import 'package:sembast/sembast_memory.dart';

import 'i_local_storage.dart';

/// Implementation of [ILocalStorage] backed by Sembast NoSQL database.
final class SembastLocalStorage implements ILocalStorage {
  final Database _database;

  const SembastLocalStorage(this._database);

  /// Creates an in-memory [SembastLocalStorage] instance, ideal for testing.
  static Future<SembastLocalStorage> inMemory([String? name]) async {
    final factory = newDatabaseFactoryMemory();
    final db = await factory.openDatabase(name ?? 'in_memory.db');
    return SembastLocalStorage(db);
  }

  StoreRef<String, Object?> _getStore(String? store) {
    if (store == null || store.isEmpty) {
      return StoreRef<String, Object?>.main();
    }
    return StoreRef<String, Object?>(store);
  }

  // ---------------------------------------------------------------------------
  // Generic / Custom Object Storage
  // ---------------------------------------------------------------------------

  @override
  Future<T?> get<T>(
    String key, {
    String? store,
    T? defaultValue,
    T Function(Map<String, dynamic> json)? decoder,
  }) async {
    final record = _getStore(store).record(key);
    final raw = await record.get(_database);

    if (raw == null) {
      return defaultValue;
    }

    if (decoder != null && raw is Map) {
      return decoder(Map<String, dynamic>.from(raw));
    }

    if (T == double && raw is num) {
      return raw.toDouble() as T;
    }

    if (raw is T) {
      return raw as T;
    }

    if (T == (List<String>) && raw is List) {
      return raw.cast<String>() as T;
    }

    return defaultValue;
  }

  @override
  Future<void> set<T>(
    String key,
    T value, {
    String? store,
    Map<String, dynamic> Function(T value)? encoder,
  }) async {
    final record = _getStore(store).record(key);
    final Object? dataToStore = encoder != null ? encoder(value) : value;

    if (dataToStore == null) {
      await record.delete(_database);
    } else {
      await record.put(_database, dataToStore);
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience Primitive Key-Value Methods
  // ---------------------------------------------------------------------------

  @override
  Future<String?> getString(
    String key, {
    String? store,
    String? defaultValue,
  }) {
    return get<String>(key, store: store, defaultValue: defaultValue);
  }

  @override
  Future<void> setString(
    String key,
    String value, {
    String? store,
  }) {
    return set<String>(key, value, store: store);
  }

  @override
  Future<bool?> getBool(
    String key, {
    String? store,
    bool? defaultValue,
  }) {
    return get<bool>(key, store: store, defaultValue: defaultValue);
  }

  @override
  Future<void> setBool(
    String key,
    bool value, {
    String? store,
  }) {
    return set<bool>(key, value, store: store);
  }

  @override
  Future<int?> getInt(
    String key, {
    String? store,
    int? defaultValue,
  }) {
    return get<int>(key, store: store, defaultValue: defaultValue);
  }

  @override
  Future<void> setInt(
    String key,
    int value, {
    String? store,
  }) {
    return set<int>(key, value, store: store);
  }

  @override
  Future<double?> getDouble(
    String key, {
    String? store,
    double? defaultValue,
  }) async {
    final value = await get<num>(key, store: store);
    return value?.toDouble() ?? defaultValue;
  }

  @override
  Future<void> setDouble(
    String key,
    double value, {
    String? store,
  }) {
    return set<double>(key, value, store: store);
  }

  @override
  Future<List<String>?> getStringList(
    String key, {
    String? store,
    List<String>? defaultValue,
  }) async {
    final raw = await _getStore(store).record(key).get(_database);
    if (raw is List) {
      return raw.cast<String>();
    }
    return defaultValue;
  }

  @override
  Future<void> setStringList(
    String key,
    List<String> value, {
    String? store,
  }) {
    return set<List<String>>(key, value, store: store);
  }

  @override
  Future<Map<String, dynamic>?> getJson(
    String key, {
    String? store,
  }) async {
    final raw = await _getStore(store).record(key).get(_database);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  @override
  Future<void> setJson(
    String key,
    Map<String, dynamic> value, {
    String? store,
  }) {
    return set<Map<String, dynamic>>(key, value, store: store);
  }

  // ---------------------------------------------------------------------------
  // Key & Store Management
  // ---------------------------------------------------------------------------

  @override
  Future<bool> containsKey(
    String key, {
    String? store,
  }) async {
    return _getStore(store).record(key).exists(_database);
  }

  @override
  Future<void> remove(
    String key, {
    String? store,
  }) async {
    await _getStore(store).record(key).delete(_database);
  }

  @override
  Future<Set<String>> getKeys({
    String? store,
  }) async {
    final keys = await _getStore(store).findKeys(_database);
    return keys.toSet();
  }

  @override
  Future<Map<String, dynamic>> getAll({
    String? store,
  }) async {
    final records = await _getStore(store).find(_database);
    return {
      for (final record in records)
        record.key: record.value is Map
            ? Map<String, dynamic>.from(record.value as Map)
            : record.value,
    };
  }

  @override
  Future<void> clear({
    String? store,
  }) async {
    await _getStore(store).delete(_database);
  }

  // ---------------------------------------------------------------------------
  // Reactive Streams
  // ---------------------------------------------------------------------------

  @override
  Stream<T?> watch<T>(
    String key, {
    String? store,
    T Function(Map<String, dynamic> json)? decoder,
  }) {
    final record = _getStore(store).record(key);
    return record.onSnapshot(_database).map((snapshot) {
      final raw = snapshot?.value;
      if (raw == null) return null;

      if (decoder != null && raw is Map) {
        return decoder(Map<String, dynamic>.from(raw));
      }

      if (T == double && raw is num) {
        return raw.toDouble() as T;
      }

      if (raw is T) {
        return raw as T;
      }

      if (T == (List<String>) && raw is List) {
        return raw.cast<String>() as T;
      }

      return null;
    });
  }

  @override
  Stream<Map<String, dynamic>> watchAll({
    String? store,
  }) {
    final storeRef = _getStore(store);
    return storeRef.query().onSnapshots(_database).map((snapshots) {
      return {
        for (final record in snapshots)
          record.key: record.value is Map
              ? Map<String, dynamic>.from(record.value as Map)
              : record.value,
      };
    });
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() {
    return _database.close();
  }
}
