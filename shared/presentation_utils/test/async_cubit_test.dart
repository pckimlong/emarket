import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain_primitives/domain_primitives.dart';
import 'package:presentation_utils/presentation_utils.dart';
import 'package:test/test.dart';

class CustomBaseCubit<S> extends Cubit<S> {
  CustomBaseCubit(super.initialState);
}

class MixinTestCubit extends CustomBaseCubit<AsyncState<int>>
    with AsyncCubitMixin<int> {
  MixinTestCubit() : super(const AsyncState.loading());

  Future<void> loadTaskEither(Result<int> task) => emitEitherGuard(task.run);

  Future<void> loadEither(Future<Either<Failure, int>> Function() cb) =>
      emitEitherGuard(cb);

  Future<void> loadFuture(Future<int> Function() cb) => emitGuard(cb);
}

class BaseClassTestCubit extends AsyncCubit<int> {
  BaseClassTestCubit() : super(const AsyncState.loading());

  Future<void> load(int val) => emitGuard(() => val);
}

void main() {
  group('AsyncCubitMixin', () {
    test('works with TaskEither', () async {
      final cubit = MixinTestCubit();
      expect(cubit.state, const AsyncState<int>.loading());

      await cubit.loadTaskEither(TaskEither.right(100));

      expect(cubit.state, const AsyncState<int>.data(100));
      await cubit.close();
    });

    test('preserves previous value on reload', () async {
      final cubit = MixinTestCubit();
      await cubit.loadFuture(() async => 10);
      expect(cubit.state, const AsyncState<int>.data(10));

      final future = cubit.loadFuture(() async => 20);
      expect(cubit.state.isRefreshing, isTrue);
      expect(cubit.state.valueOrNull, 10);

      await future;
      expect(cubit.state, const AsyncState<int>.data(20));
      await cubit.close();
    });

    test('listens to stream and transitions through states', () async {
      final cubit = MixinTestCubit();
      final controller = StreamController<int>();

      final sub = cubit.emitStreamGuard(controller.stream);
      expect(cubit.state, const AsyncState<int>.loading());

      controller.add(42);
      await pumpEventQueue();
      expect(cubit.state, const AsyncState<int>.data(42));

      controller.addError(Exception('stream failure'));
      await pumpEventQueue();
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.valueOrNull, 42); // preserves previous on error
      expect(cubit.state, isA<AsyncFailureState<int>>());

      await sub.cancel();
      await controller.close();
      await cubit.close();
    });
  });

  group('AsyncCubit', () {
    test('extends Cubit with mixin', () async {
      final cubit = BaseClassTestCubit();
      await cubit.load(42);
      expect(cubit.state, const AsyncState<int>.data(42));
      await cubit.close();
    });
  });
}
