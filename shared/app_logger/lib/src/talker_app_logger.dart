import 'package:talker/talker.dart';

import 'app_logger.dart';

/// An [AppLogger] implementation backed by [Talker].
final class TalkerAppLogger implements AppLogger {
  const TalkerAppLogger(this.talker);

  /// The underlying [Talker] instance.
  final Talker talker;

  @override
  void debug(dynamic message, [Object? error, StackTrace? stackTrace]) {
    talker.debug(message, error, stackTrace);
  }

  @override
  void info(dynamic message, [Object? error, StackTrace? stackTrace]) {
    talker.info(message, error, stackTrace);
  }

  @override
  void warning(dynamic message, [Object? error, StackTrace? stackTrace]) {
    talker.warning(message, error, stackTrace);
  }

  @override
  void error(dynamic message, [Object? error, StackTrace? stackTrace]) {
    talker.error(message, error, stackTrace);
  }

  @override
  void critical(dynamic message, [Object? error, StackTrace? stackTrace]) {
    talker.critical(message, error, stackTrace);
  }

  @override
  void handle(Object error, [StackTrace? stackTrace, dynamic message]) {
    talker.handle(error, stackTrace, message);
  }
}
