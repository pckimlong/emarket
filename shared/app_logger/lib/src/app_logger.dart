import 'package:talker/talker.dart';

import 'no_op_app_logger.dart';
import 'talker_app_logger.dart';

/// Contract for application-wide logging and diagnostics.
///
/// Pure Dart interface suitable for use across domain, data, backend,
/// and presentation layers.
abstract interface class AppLogger {
  /// Ambient root logger instance across the application.
  ///
  /// Defaults to [NoOpAppLogger] until initialized by bootstrap.
  static AppLogger root = const NoOpAppLogger();

  /// Creates a logger backed by a [Talker] instance.
  factory AppLogger.talker(Talker talker) = TalkerAppLogger;

  /// Creates a no-op logger that discards all log events (useful for tests).
  const factory AppLogger.noOp() = NoOpAppLogger;

  /// Logs a debug level message.
  void debug(dynamic message, [Object? error, StackTrace? stackTrace]);

  /// Logs an informational message.
  void info(dynamic message, [Object? error, StackTrace? stackTrace]);

  /// Logs a warning message.
  void warning(dynamic message, [Object? error, StackTrace? stackTrace]);

  /// Logs an error message.
  void error(dynamic message, [Object? error, StackTrace? stackTrace]);

  /// Logs a critical / fatal message.
  void critical(dynamic message, [Object? error, StackTrace? stackTrace]);

  /// Handles and logs an unhandled or caught exception.
  void handle(Object error, [StackTrace? stackTrace, dynamic message]);
}
