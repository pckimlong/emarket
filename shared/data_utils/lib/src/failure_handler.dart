import 'package:app_logger/app_logger.dart';
import 'package:domain_primitives/domain_primitives.dart';
import 'package:emarket_client/emarket_client.dart';

bool kAlwaysShowDetailedErrors = false;

/// Converts any caught error/exception into a domain [Failure], logging it via [AppLogger].
Failure toFailure(Object e, StackTrace st) {
  if (e is Failure) return e;

  AppLogger.root.handle(e, st, 'Data layer: ${e.runtimeType}');

  final message = switch (e) {
    NotFoundException(:final message) => message,
    ForbiddenException(:final message) => message,
    UnauthorizedException(:final message) => message,
    ConflictException(:final message) => message,
    ValidationException(:final message) => message,
    BusinessException(:final message) => message,
    ServerpodClientException(:final message) => message,
    _ => null,
  };

  return Failure(
    error: e,
    stackTrace: st,
    message: message,
  );
}

Result<T> failureHandler<T>(Future<T> Function() func) {
  return TaskEither.tryCatch(func, toFailure);
}
