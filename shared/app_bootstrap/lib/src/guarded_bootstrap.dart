import 'dart:async';

/// Runs startup and its asynchronous descendants in one guarded zone.
///
/// The returned future belongs to the caller's zone, so startup failures remain
/// awaitable rather than getting trapped across an error-zone boundary. Success
/// means startup returned, not that the first frame rendered successfully.
Future<void> runGuardedBootstrap(
  FutureOr<void> Function() start, {
  required void Function(Object error, StackTrace stackTrace) reportError,
}) {
  final started = Completer<void>();
  runZonedGuarded(
    () async {
      try {
        await start();
        if (!started.isCompleted) started.complete();
      } catch (error, stackTrace) {
        // Let the caller handle awaited startup failures. The zone handler is
        // reserved for uncaught asynchronous work spawned by startup/the app.
        if (!started.isCompleted) {
          started.completeError(error, stackTrace);
        } else {
          reportError(error, stackTrace);
        }
      }
    },
    (error, stackTrace) {
      reportError(error, stackTrace);
      if (!started.isCompleted) started.completeError(error, stackTrace);
    },
  );
  return started.future;
}
