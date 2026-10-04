import 'package:presentation_utils/presentation_utils.dart';
import 'package:test/test.dart';

void main() {
  test('guardFuture emits loading and data for a synchronous value', () async {
    final states = <AsyncState<int>>[];

    await AsyncState.guardFuture(states.add, () => 42);

    expect(states, [
      const AsyncState<int>.loading(),
      const AsyncState<int>.data(42),
    ]);

    expect(states[0].isInitialLoading, isTrue);
    expect(states[0].isLoading, isTrue);
    expect(states[0].isRefreshing, isFalse);
    expect(states[0].hasValue, isFalse);
    expect(states[0].valueOrNull, isNull);

    expect(states[1].hasValue, isTrue);
    expect(states[1].valueOrNull, 42);
    expect(states[1].isLoading, isFalse);
  });

  test('guardFuture preserves previous data while refreshing', () async {
    final states = <AsyncState<int>>[];

    await AsyncState.guardFuture(
      states.add,
      () => Future<int>.value(2),
      previous: 1,
    );

    expect(states, [
      const AsyncState<int>.loading(previous: 1),
      const AsyncState<int>.data(2),
    ]);

    expect(states[0].isRefreshing, isTrue);
    expect(states[0].isInitialLoading, isFalse);
    expect(states[0].isLoading, isTrue);
    expect(states[0].hasValue, isTrue);
    expect(states[0].valueOrNull, 1);

    expect(states[1].valueOrNull, 2);
    expect(states[1].hasValue, isTrue);
  });

  test('guardFuture converts thrown errors to failures', () async {
    final states = <AsyncState<int>>[];
    final error = StateError('offline');

    await AsyncState.guardFuture<int>(
      states.add,
      () => throw error,
      previous: 1,
    );

    expect(states.first, const AsyncState<int>.loading(previous: 1));
    final failure = states.last as AsyncFailureState<int>;
    expect(failure.failure.error, same(error));
    expect(failure.previous, 1);
    expect(failure.hasValue, isTrue);
    expect(failure.valueOrNull, 1);
    expect(failure.isLoading, isFalse);
  });
}
