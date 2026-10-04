import 'package:app_bootstrap/app_bootstrap.dart';
import 'package:auth_data/auth_data.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app_providers.dart';
import 'app/app_widget.dart';

export 'package:app_bootstrap/app_bootstrap.dart';

/// Composes configured infrastructure and mounts the application provider tree.
Future<void> bootstrapApp({required BootstrapConfig config, Talker? talker}) {
  return BootstrapRunner.run(
    talker: talker,
    builder: (talker) async {
      final firebaseOptions = config.firebaseOptions;
      if (firebaseOptions != null) {
        await Firebase.initializeApp(options: firebaseOptions);
      }

      final serverpod = await initializeServerpod(config);
      final authRepo = AuthRepoImpl(
        client: serverpod.client,
        sessionManager: serverpod.sessionManager,
      );

      return RepositoryProvider<Client>(
        lazy: false,
        create: (_) => serverpod.client,
        dispose: (client) => client.close(),
        child: AppProviders(
          config: config,
          talker: talker,
          authRepo: authRepo,
          child: const AppWidget(),
        ),
      );
    },
  );
}
