import 'app_logger.dart';

/// Mixin that provides convenient, class-tagged logging methods.
///
/// Automatically prefixes log messages with the class name ([loggerTag]).
mixin LoggerMixin {
  /// The logger instance used by this class. Defaults to [AppLogger.root].
  AppLogger get logger => AppLogger.root;

  /// The tag attached to logs from this class. Defaults to [runtimeType].
  String get loggerTag => runtimeType.toString();

  /// Logs a debug level message prefixed with [loggerTag].
  void logDebug(dynamic message, [Object? error, StackTrace? stackTrace]) {
    logger.debug('[$loggerTag] $message', error, stackTrace);
  }

  /// Logs an informational message prefixed with [loggerTag].
  void logInfo(dynamic message, [Object? error, StackTrace? stackTrace]) {
    logger.info('[$loggerTag] $message', error, stackTrace);
  }

  /// Logs a warning message prefixed with [loggerTag].
  void logWarning(dynamic message, [Object? error, StackTrace? stackTrace]) {
    logger.warning('[$loggerTag] $message', error, stackTrace);
  }

  /// Logs an error message prefixed with [loggerTag].
  void logError(dynamic message, [Object? error, StackTrace? stackTrace]) {
    logger.error('[$loggerTag] $message', error, stackTrace);
  }

  /// Logs a critical / fatal message prefixed with [loggerTag].
  void logCritical(dynamic message, [Object? error, StackTrace? stackTrace]) {
    logger.critical('[$loggerTag] $message', error, stackTrace);
  }

  /// Handles and logs an exception prefixed with [loggerTag].
  void logException(Object error, [StackTrace? stackTrace, dynamic message]) {
    final prefix = '[$loggerTag]';
    final formattedMessage = message == null ? prefix : '$prefix $message';
    logger.handle(error, stackTrace, formattedMessage);
  }
}
