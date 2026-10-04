import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain_primitives/domain_primitives.dart';
import 'package:presentation_utils/src/async_state_model.dart';

/// Extension on any [Emitter] (including BLoCs with custom state classes)
/// that provides an error-guarded [onEachGuard] converting uncaught stream errors into [Failure].
extension EmitterGuardX<State> on Emitter<State> {
  /// Listens to [stream] and safely handles incoming data and errors,
  /// automatically converting any uncaught stream errors into a typed [Failure].
  Future<void> onEachGuard<S>(
    Stream<S> stream, {
    required FutureOr<void> Function(S data) onData,
    FutureOr<void> Function(Failure failure, StackTrace stackTrace)? onError,
  }) {
    return onEach<S>(
      stream,
      onData: onData,
      onError: (error, stackTrace) {
        final failure = error is Failure
            ? error
            : Failure(error: error, stackTrace: stackTrace);
        onError?.call(failure, stackTrace);
      },
    );
  }

  /// Listens to [stream] and automatically manages [AsyncState] transitions for a
  /// specific property within a composite [State].
  ///
  /// 1. Optionally emits [AsyncState.loading] with [previous] preserved,
  ///    if [current] is not already loading.
  /// 2. For each incoming event from [stream], maps it via [onData] (or casts directly if omitted)
  ///    and emits [AsyncState.data].
  /// 3. If an error occurs on the stream, converts it into a typed [Failure] and emits [AsyncState.error],
  ///    preserving the previous value.
  Future<void> onEachAsyncPropertyGuard<T, S>(
    Stream<S> stream, {
    required AsyncState<T> Function() current,
    required State Function(AsyncState<T> next) update,
    FutureOr<T> Function(S data)? onData,
    bool emitLoadingIfNeeded = true,
  }) async {
    var lastValue = current().valueOrNull;

    if (emitLoadingIfNeeded && current() is! AsyncLoadingState<T>) {
      call(update(AsyncState.loading(previous: lastValue)));
    }

    await onEachGuard<S>(
      stream,
      onData: (data) async {
        final mapped = onData != null ? await onData(data) : data as T;
        lastValue = mapped;
        call(update(AsyncState.data(mapped)));
      },
      onError: (failure, _) {
        call(update(AsyncState.error(failure, previous: lastValue)));
      },
    );
  }
}

/// Extension on [Emitter<AsyncState<T>>] for BLoCs managing raw [AsyncState<T>].
extension AsyncStateEmitterX<T> on Emitter<AsyncState<T>> {
  /// Listens to [stream] and automatically manages [AsyncState] transitions.
  ///
  /// 1. Optionally emits [AsyncState.loading] with [previous] preserved.
  /// 2. For each incoming event from [stream], maps it via [onData] (or casts directly if omitted)
  ///    and emits [AsyncState.data].
  /// 3. If an error occurs on the stream, converts it into a [Failure] and emits [AsyncState.error],
  ///    preserving [previous].
  Future<void> onEachAsyncStateGuard<S>(
    Stream<S> stream, {
    FutureOr<T> Function(S data)? onData,
    T? previous,
    bool emitLoading = true,
  }) async {
    var lastValue = previous;

    if (emitLoading) {
      call(AsyncState.loading(previous: previous));
    }

    await onEach<S>(
      stream,
      onData: (data) async {
        final mapped = onData != null ? await onData(data) : data as T;
        lastValue = mapped;
        call(AsyncState.data(mapped));
      },
      onError: (error, stackTrace) {
        final failure = error is Failure
            ? error
            : Failure(error: error, stackTrace: stackTrace);
        call(AsyncState.error(failure, previous: lastValue));
      },
    );
  }
}
