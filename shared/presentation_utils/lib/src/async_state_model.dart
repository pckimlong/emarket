import 'dart:async';

import 'package:domain_primitives/domain_primitives.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'async_state_model.freezed.dart';

@freezed
sealed class AsyncState<T> with _$AsyncState<T> {
  const factory AsyncState.loading({T? previous}) = AsyncLoadingState;
  const factory AsyncState.error(
    Failure failure, {
    T? previous,
  }) = AsyncFailureState;
  const factory AsyncState.data(T value) = AsyncDataState;

  static Future<void> guard<T>(
    void Function(AsyncState<T> value) emit,
    Future<Either<Failure, T>> Function() callback, {
    T? previous,
  }) async {
    emit(AsyncState.loading(previous: previous));

    final result = await callback();
    result.fold(
      (failure) => emit(AsyncState.error(failure, previous: previous)),
      (value) => emit(AsyncState.data(value)),
    );
  }

  static Future<void> guardFuture<T>(
    void Function(AsyncState<T> value) emit,
    FutureOr<T> Function() callback, {
    T? previous,
  }) async {
    emit(AsyncState.loading(previous: previous));

    try {
      final value = await callback();
      emit(AsyncState.data(value));
    } catch (error, stackTrace) {
      final failure = error is Failure
          ? error
          : Failure(error: error, stackTrace: stackTrace);
      emit(AsyncState.error(failure, previous: previous));
    }
  }
}

extension AsyncStateValue<T> on AsyncState<T> {
  T? get valueOrNull => switch (this) {
    AsyncLoadingState(:final previous) => previous,
    AsyncFailureState(:final previous) => previous,
    AsyncDataState(:final value) => value,
  };

  bool get hasValue => valueOrNull != null;

  bool get isRefreshing => this is AsyncLoadingState<T> && hasValue;

  bool get isInitialLoading => this is AsyncLoadingState<T> && !hasValue;

  bool get isLoading => this is AsyncLoadingState<T>;
}
