import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain_primitives/domain_primitives.dart';
import 'package:presentation_utils/presentation_utils.dart';

/// Mixin providing async guard methods to any [Cubit] managing [AsyncState].
mixin AsyncCubitMixin<T> on Cubit<AsyncState<T>> {
  Future<void> emitEitherGuard(
    FutureOr<Either<Failure, T>> Function() callback, {
    bool preservePrevious = true,
  }) {
    return AsyncState.guard(
      emit,
      () async => await callback(),
      previous: preservePrevious ? state.valueOrNull : null,
    );
  }

  Future<void> emitGuard(
    FutureOr<T> Function() callback, {
    bool preservePrevious = true,
  }) {
    return AsyncState.guardFuture(
      emit,
      callback,
      previous: preservePrevious ? state.valueOrNull : null,
    );
  }

  /// Listens to a [Stream<T>] and automatically emits [AsyncState.data] or [AsyncState.error].
  StreamSubscription<T> emitStreamGuard(
    Stream<T> stream, {
    bool preservePrevious = true,
  }) {
    emit(
      AsyncState.loading(previous: preservePrevious ? state.valueOrNull : null),
    );
    return stream.listen(
      (data) => emit(AsyncState.data(data)),
      onError: (error, stackTrace) {
        final failure = error is Failure
            ? error
            : Failure(error: error, stackTrace: stackTrace);
        emit(
          AsyncState.error(
            failure,
            previous: preservePrevious ? state.valueOrNull : null,
          ),
        );
      },
    );
  }
}

/// Base [Cubit] that mixes in [AsyncCubitMixin].
abstract class AsyncCubit<T> extends Cubit<AsyncState<T>>
    with AsyncCubitMixin<T> {
  AsyncCubit([super.initialState = const AsyncState.loading()]);
}
