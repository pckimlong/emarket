import 'package:emarket_client/emarket_client.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bootstrap_config.dart';

final class SharedPreferencesKeyValueStorage implements KeyValueStorage {
  const SharedPreferencesKeyValueStorage(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<String?> get(String key) async => _prefs.getString(key);

  @override
  Future<void> set(String key, String? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }
}

Future<({Client client, ClientAuthSessionManager sessionManager})>
initializeServerpod(
  BootstrapConfig config,
) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final storage = KeyValueClientAuthSuccessStorage(
    keyValueStorage: SharedPreferencesKeyValueStorage(sharedPreferences),
  );

  final sessionManager = ClientAuthSessionManager(storage: storage);
  final client = Client(
    config.serverUrl,
  )..authKeyProvider = sessionManager;
  sessionManager.setCaller(client.modules.serverpod_auth_core);
  try {
    await sessionManager.initialize();
  } catch (_) {
    client.close();
    rethrow;
  }

  return (client: client, sessionManager: sessionManager);
}
