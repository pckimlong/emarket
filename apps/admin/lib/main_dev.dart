import 'bootstrap.dart';

Future<void> main() => bootstrapApp(
  config: .new(
    env: IntegrationMode.develop,
    serverUrl: const String.fromEnvironment(
      'SERVER_URL',
      defaultValue: 'http://localhost:8080/',
    ),
  ),
);
