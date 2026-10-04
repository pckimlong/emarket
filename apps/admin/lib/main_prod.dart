import 'package:admin/bootstrap.dart';

Future<void> main() => bootstrapApp(
  config: .new(
    env: IntegrationMode.prod,
    serverUrl: const String.fromEnvironment('SERVER_URL'),
  ),
);
