import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation_utils/presentation_utils.dart';

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);
}

void main() {
  testWidgets('returns content without requiring a provider when omitted', (
    tester,
  ) async {
    const content = SizedBox(key: ValueKey('content'));
    await tester.pumpWidget(
      const BlocModuleHost<_CounterCubit>(content: content),
    );
    expect(find.byWidget(content), findsOneWidget);
  });

  testWidgets('exposes provider context and leaves ownership with provider', (
    tester,
  ) async {
    late _CounterCubit cubit;
    const content = SizedBox(key: ValueKey('content'));
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => cubit = _CounterCubit(),
        child: BlocModuleHost<_CounterCubit>(
          content: content,
          builder: (context, bloc, child) {
            expect(bloc, same(cubit));
            expect(context.read<_CounterCubit>(), same(bloc));
            expect(child, same(content));
            return BlocSelector<_CounterCubit, int, int>(
              bloc: bloc,
              selector: (state) => state,
              builder: (_, value) => SizedBox(
                key: ValueKey(value),
                child: child,
              ),
            );
          },
        ),
      ),
    );
    expect(cubit.isClosed, isFalse);
    cubit.emit(1);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey(1)), findsOneWidget);
    expect(find.byWidget(content), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    expect(cubit.isClosed, isTrue);
  });
}
