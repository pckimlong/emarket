import 'package:admin/modules/log/talker_page.dart';
import 'package:app_bootstrap/app_bootstrap.dart';
import 'package:app_logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _TestCubit extends Cubit<int> {
  _TestCubit() : super(0);

  void increment() => emit(state + 1);
  void triggerError() => addError(Exception('test error'));
}

void main() {
  testWidgets(
    'BootstrapRunner configures Talker, AppLogger.root, and TalkerBlocObserver',
    (
      tester,
    ) async {
      final talker = Talker(
        settings: TalkerSettings(
          useConsoleLogs: false,
        ),
      );

      await BootstrapRunner.run(
        talker: talker,
        builder: (t) {
          expect(t, same(talker));
          return const MaterialApp(
            home: Scaffold(
              body: Text('Ready'),
            ),
          );
        },
      );

      expect(Bloc.observer, isA<TalkerBlocObserver>());
      expect(AppLogger.root, isA<TalkerAppLogger>());

      // Test that ambient AppLogger logs to Talker
      AppLogger.root.info('Ambient log from test');
      expect(
        talker.history.any((log) => log.message == 'Ambient log from test'),
        isTrue,
      );

      // Test that BLoC events / transitions are logged to Talker
      final cubit = _TestCubit();
      cubit.increment();
      cubit.triggerError();
      await cubit.close();

      expect(talker.history.isNotEmpty, isTrue);
    },
  );

  testWidgets('TalkerPage renders TalkerScreen with logs', (tester) async {
    final talker = Talker(
      settings: TalkerSettings(
        useConsoleLogs: false,
      ),
    );
    talker.info('Test talker info message');

    await tester.pumpWidget(
      RepositoryProvider<Talker>.value(
        value: talker,
        child: const MaterialApp(
          // ignore: deprecated_member_use
          home: MaterialUiCompatibilityBridge(
            child: TalkerPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(TalkerScreen), findsOneWidget);
    expect(find.textContaining('Test talker info message'), findsOneWidget);
  });
}
