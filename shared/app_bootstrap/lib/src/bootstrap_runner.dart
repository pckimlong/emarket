import 'dart:async';
import 'dart:ui';

import 'package:app_logger/app_logger.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'crashlytics_talker_observer.dart';
import 'guarded_bootstrap.dart';

/// Owns Flutter startup mechanics, error boundaries, and telemetry initialization.
///
/// [run] initializes the binding and BLoC infrastructure, invokes the app's
/// composition builder, and mounts its result in the same guarded zone.
abstract final class BootstrapRunner {
  /// Completes when runApp returns, or fails with the original startup error.
  /// The builder must return the root widget; it must not call runApp itself.
  static Future<void> run({
    Talker? talker,
    required FutureOr<Widget> Function(Talker talker) builder,
  }) {
    final effectiveTalker =
        talker ??
        TalkerFlutter.init(
          observer: const CrashlyticsTalkerObserver(),
        );
    AppLogger.root = TalkerAppLogger(effectiveTalker);
    return runGuardedBootstrap(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        FlutterError.onError = (details) {
          FlutterError.presentError(details);
          effectiveTalker.handle(details.exception, details.stack);
        };
        PlatformDispatcher.instance.onError = (error, stackTrace) {
          _reportError(effectiveTalker, error, stackTrace);
          return true;
        };
        Bloc.observer = TalkerBlocObserver(
          talker: effectiveTalker,
          settings: const TalkerBlocLoggerSettings(
            printEventFullData: false,
            printStateFullData: false,
            printChanges: true,
          ),
        );
        final app = await builder(effectiveTalker);
        runApp(app);
      },
      reportError: (error, stackTrace) =>
          _reportError(effectiveTalker, error, stackTrace),
    );
  }

  static void _reportError(
    Talker talker,
    Object error,
    StackTrace stackTrace,
  ) {
    talker.handle(
      error,
      stackTrace,
      'Unhandled application error',
    );
  }
}
