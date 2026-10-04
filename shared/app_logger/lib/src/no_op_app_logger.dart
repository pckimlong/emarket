import 'app_logger.dart';

/// A no-op implementation of [AppLogger] that silences all log messages.
final class NoOpAppLogger implements AppLogger {
  const NoOpAppLogger();

  @override
  void debug(dynamic message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void info(dynamic message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void warning(dynamic message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void error(dynamic message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void critical(dynamic message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void handle(Object error, [StackTrace? stackTrace, dynamic message]) {}
}
