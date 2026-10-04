import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain_primitives/domain_primitives.dart';
import 'package:presentation_utils/presentation_utils.dart';
import 'package:test/test.dart';

sealed class const TestEvent();

final class const LoadTaskEitherEvent(final Result<int> task) extends TestEvent;

final class const LoadFutureEvent(final int value) extends TestEvent;

final class LoadStreamEvent extends TestEvent {
  final Stream<int> stream;
  const LoadStreamEvent(this.stream);
}

final class LoadMappedStreamEvent extends TestEvent {
  final Stream<String> stream;
  const LoadMappedStreamEvent(this.stream);
}

class CustomBaseBloc<E, S> extends Bloc<E, S> {
  CustomBaseBloc(super.initialState);
}

class MixinTestBloc extends CustomBaseBloc<TestEvent, AsyncState<int>>
    with AsyncBlocMixin<TestEvent, int> {
  MixinTestBloc() : super(const AsyncState.loading()) {
    on<LoadTaskEitherEvent>(
      (event, emit) => emitEitherGuard(emit, event.task.run),
    );
    on<LoadFutureEvent>((event, emit) => emitGuard(emit, () => event.value));
    on<LoadStreamEvent>((event, emit) => emitStreamGuard(emit, event.stream));
    on<LoadMappedStreamEvent>(
      (event, emit) => emit.onEachAsyncStateGuard(
        event.stream,
        previous: state.valueOrNull,
        onData: (str) => int.parse(str),
      ),
    );
  }
}

class BaseClassTestBloc extends AsyncBloc<TestEvent, int> {
  BaseClassTestBloc() : super(const AsyncState.loading()) {
    on<LoadFutureEvent>((event, emit) => emitGuard(emit, () => event.value));
  }
}

class CompositeTestState {
  final AsyncState<int> count;
  final String filter;

  const CompositeTestState({
    this.count = const AsyncState.loading(),
    this.filter = 'all',
  });

  CompositeTestState copyWith({
    AsyncState<int>? count,
    String? filter,
  }) {
    return CompositeTestState(
      count: count ?? this.count,
      filter: filter ?? this.filter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositeTestState &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          filter == other.filter;

  @override
  int get hashCode => count.hashCode ^ filter.hashCode;
}

final class WatchCountStreamEvent extends TestEvent {
  final Stream<int> stream;
  const WatchCountStreamEvent(this.stream);
}

final class WatchMappedCountStreamEvent extends TestEvent {
  final Stream<String> stream;
  const WatchMappedCountStreamEvent(this.stream);
}

class CompositeTestBloc extends Bloc<TestEvent, CompositeTestState> {
  CompositeTestBloc([super.initialState = const CompositeTestState()]) {
    on<WatchCountStreamEvent>((event, emit) {
      return emit.onEachAsyncPropertyGuard<int, int>(
        event.stream,
        current: () => state.count,
        update: (count) => state.copyWith(count: count),
      );
    });
    on<WatchMappedCountStreamEvent>((event, emit) {
      return emit.onEachAsyncPropertyGuard<int, String>(
        event.stream,
        current: () => state.count,
        update: (count) => state.copyWith(count: count),
        onData: (str) => int.parse(str),
      );
    });
  }
}

void main() {
  group('AsyncBlocMixin', () {
    test('handles TaskEither events', () async {
      final bloc = MixinTestBloc();
      expect(bloc.state, const AsyncState<int>.loading());

      bloc.add(LoadTaskEitherEvent(TaskEither.right(100)));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const AsyncState<int>.loading(),
          const AsyncState<int>.data(100),
        ]),
      );
      await bloc.close();
    });

    test('preserves previous value while refreshing', () async {
      final bloc = MixinTestBloc();
      bloc.add(const LoadFutureEvent(10));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const AsyncState<int>.loading(),
          const AsyncState<int>.data(10),
        ]),
      );

      bloc.add(const LoadFutureEvent(20));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const AsyncState<int>.loading(previous: 10),
          const AsyncState<int>.data(20),
        ]),
      );
      await bloc.close();
    });

    test('handles stream events via emitStreamGuard', () async {
      final bloc = MixinTestBloc();
      final stream = Stream.fromIterable([1, 2, 3]);

      bloc.add(LoadStreamEvent(stream));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const AsyncState<int>.loading(),
          const AsyncState<int>.data(1),
          const AsyncState<int>.data(2),
          const AsyncState<int>.data(3),
        ]),
      );
      await bloc.close();
    });

    test(
      'handles mapped stream events and converts errors via emit.onEachGuard',
      () async {
        final bloc = MixinTestBloc();
        final controller = StreamController<String>();

        bloc.add(LoadMappedStreamEvent(controller.stream));

        controller.add('42');
        controller.addError(Exception('Stream failure'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const AsyncState<int>.loading(),
            const AsyncState<int>.data(42),
            predicate<AsyncState<int>>(
              (s) => s is AsyncFailureState<int> && s.previous == 42,
            ),
          ]),
        );

        await controller.close();
        await bloc.close();
      },
    );
  });

  group('AsyncBloc', () {
    test('extends Bloc with mixin', () async {
      final bloc = BaseClassTestBloc();
      bloc.add(const LoadFutureEvent(42));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const AsyncState<int>.loading(),
          const AsyncState<int>.data(42),
        ]),
      );
      await bloc.close();
    });
  });

  group('onEachAsyncPropertyGuard', () {
    test('handles stream events on composite state without duplicating initial loading', () async {
      final bloc = CompositeTestBloc();
      final stream = Stream.fromIterable([1, 2, 3]);

      bloc.add(WatchCountStreamEvent(stream));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const CompositeTestState(count: AsyncState.data(1)),
          const CompositeTestState(count: AsyncState.data(2)),
          const CompositeTestState(count: AsyncState.data(3)),
        ]),
      );
      await bloc.close();
    });

    test('emits loading preserving previous value when refreshing', () async {
      final bloc = CompositeTestBloc(
        const CompositeTestState(count: AsyncState.data(10)),
      );
      final stream = Stream.fromIterable([20]);

      bloc.add(WatchCountStreamEvent(stream));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const CompositeTestState(count: AsyncState.loading(previous: 10)),
          const CompositeTestState(count: AsyncState.data(20)),
        ]),
      );
      await bloc.close();
    });

    test(
      'maps stream events and converts errors preserving last value',
      () async {
        final bloc = CompositeTestBloc();
        final controller = StreamController<String>();

        bloc.add(WatchMappedCountStreamEvent(controller.stream));

        controller.add('99');
        controller.addError('Something broke');

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const CompositeTestState(count: AsyncState.data(99)),
            predicate<CompositeTestState>(
              (s) =>
                  s.count is AsyncFailureState<int> &&
                  s.count.valueOrNull == 99 &&
                  s.filter == 'all',
            ),
          ]),
        );

        await controller.close();
        await bloc.close();
      },
    );
  });
}
