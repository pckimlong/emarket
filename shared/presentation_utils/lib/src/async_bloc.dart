import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain_primitives/domain_primitives.dart';
import 'package:presentation_utils/presentation_utils.dart';

/// Mixin providing async guard methods to any [Bloc] managing [AsyncState].
mixin AsyncBlocMixin<Event, T> on Bloc<Event, AsyncState<T>> {
  Future<void> emitEitherGuard(
    Emitter<AsyncState<T>> emit,
    FutureOr<Either<Failure, T>> Function() callback, {
    bool preservePrevious = true,
  }) {
    return AsyncState.guard(
      emit.call,
      () async => await callback(),
      previous: preservePrevious ? state.valueOrNull : null,
    );
  }

  Future<void> emitGuard(
    Emitter<AsyncState<T>> emit,
    FutureOr<T> Function() callback, {
    bool preservePrevious = true,
  }) {
    return AsyncState.guardFuture(
      emit.call,
      callback,
      previous: preservePrevious ? state.valueOrNull : null,
    );
  }

  /// Listens to a [Stream<S>] and automatically emits [AsyncState.data] or [AsyncState.error].
  Future<void> emitStreamGuard<S>(
    Emitter<AsyncState<T>> emit,
    Stream<S> stream, {
    FutureOr<T> Function(S data)? onData,
    bool preservePrevious = true,
    bool emitLoading = true,
  }) {
    return emit.onEachAsyncStateGuard(
      stream,
      onData: onData,
      previous: preservePrevious ? state.valueOrNull : null,
      emitLoading: emitLoading,
    );
  }
}

/// Base [Bloc] that mixes in [AsyncBlocMixin].
abstract class AsyncBloc<Event, T> extends Bloc<Event, AsyncState<T>>
    with AsyncBlocMixin<Event, T> {
  AsyncBloc([super.initialState = const AsyncState.loading()]);
}
