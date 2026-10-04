import 'dart:async';

abstract interface class ILocalStorage {
  Future<T?> get<T>(
    String key, {
    String? store,
    T? defaultValue,
    T Function(Map<String, dynamic> json)? decoder,
  });

  Future<void> set<T>(
    String key,
    T value, {
    String? store,
    Map<String, dynamic> Function(T value)? encoder,
  });

  Future<String?> getString(
    String key, {
    String? store,
    String? defaultValue,
  });

  Future<void> setString(
    String key,
    String value, {
    String? store,
  });

  Future<bool?> getBool(
    String key, {
    String? store,
    bool? defaultValue,
  });

  Future<void> setBool(
    String key,
    bool value, {
    String? store,
  });

  Future<int?> getInt(
    String key, {
    String? store,
    int? defaultValue,
  });

  Future<void> setInt(
    String key,
    int value, {
    String? store,
  });

  Future<double?> getDouble(
    String key, {
    String? store,
    double? defaultValue,
  });

  Future<void> setDouble(
    String key,
    double value, {
    String? store,
  });

  Future<List<String>?> getStringList(
    String key, {
    String? store,
    List<String>? defaultValue,
  });

  Future<void> setStringList(
    String key,
    List<String> value, {
    String? store,
  });

  Future<Map<String, dynamic>?> getJson(
    String key, {
    String? store,
  });

  Future<void> setJson(
    String key,
    Map<String, dynamic> value, {
    String? store,
  });

  Future<bool> containsKey(
    String key, {
    String? store,
  });

  Future<void> remove(
    String key, {
    String? store,
  });

  Future<Set<String>> getKeys({
    String? store,
  });

  Future<Map<String, dynamic>> getAll({
    String? store,
  });

  Future<void> clear({
    String? store,
  });

  Stream<T?> watch<T>(
    String key, {
    String? store,
    T Function(Map<String, dynamic> json)? decoder,
  });

  Stream<Map<String, dynamic>> watchAll({
    String? store,
  });

  Future<void> close();
}
