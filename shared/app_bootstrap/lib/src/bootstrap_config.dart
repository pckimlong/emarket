import 'package:domain_primitives/domain_primitives.dart';
import 'package:firebase_core/firebase_core.dart';

export 'package:domain_primitives/domain_primitives.dart' show IntegrationMode;

/// Immutable startup configuration. Reading it never changes global state.
final class BootstrapConfig {
  const BootstrapConfig({
    required this.env,
    required this.serverUrl,
    this.firebaseOptions,
  });

  final IntegrationMode env;
  final String serverUrl;
  final FirebaseOptions? firebaseOptions;
}
