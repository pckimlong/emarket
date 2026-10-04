import 'package:presentation_utils/presentation_utils.dart';
import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

sealed class const CounterEvent();

final class const IncrementEvent(final int amount) extends CounterEvent;

class DebounceTestBloc extends Bloc<CounterEvent, int> {
  DebounceTestBloc(Duration duration) : super(0) {
    on<IncrementEvent>(
      (event, emit) => emit(state + event.amount),
      transformer: debounce(duration),
    );
  }
}

class ThrottleTestBloc extends Bloc<CounterEvent, int> {
  ThrottleTestBloc(Duration duration) : super(0) {
    on<IncrementEvent>(
      (event, emit) => emit(state + event.amount),
      transformer: throttle(duration),
    );
  }
}

void main() {
  group('debounce transformer', () {
    test('emits only the last event when events arrive rapidly', () async {
      final bloc = DebounceTestBloc(const Duration(milliseconds: 100));

      bloc.add(const IncrementEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const IncrementEvent(2));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const IncrementEvent(3));

      // Wait for debounce duration to pass
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(bloc.state, 3);
      await bloc.close();
    });
  });

  group('throttle transformer', () {
    test('emits the first event and ignores rapid subsequent events', () async {
      final bloc = ThrottleTestBloc(const Duration(milliseconds: 100));

      bloc.add(const IncrementEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const IncrementEvent(2));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const IncrementEvent(3));

      await Future<void>.delayed(const Duration(milliseconds: 150));

      // Only the first event (1) should have executed
      expect(bloc.state, 1);
      await bloc.close();
    });
  });
}
