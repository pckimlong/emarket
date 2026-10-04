import 'package:app_bootstrap/app_bootstrap.dart';
import 'package:data_utils/data_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class ITestRepo {}

class DisposableRepo implements ITestRepo, Disposable {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
  }
}

class NonDisposableRepo implements ITestRepo {}

void main() {
  group('DisposableRepositoryProvider', () {
    testWidgets(
      'calls dispose on unmount when instance implements Disposable',
      (tester) async {
        late DisposableRepo createdRepo;

        await tester.pumpWidget(
          DisposableRepoProvider<ITestRepo>(
            create: (context) {
              createdRepo = DisposableRepo();
              return createdRepo;
            },
            child: Builder(
              builder: (context) {
                context.read<ITestRepo>();
                return const SizedBox();
              },
            ),
          ),
        );

        expect(createdRepo.isDisposed, isFalse);

        await tester.pumpWidget(const SizedBox());

        expect(createdRepo.isDisposed, isTrue);
      },
    );

    testWidgets('does not throw when instance does not implement Disposable', (
      tester,
    ) async {
      late NonDisposableRepo createdRepo;

      await tester.pumpWidget(
        DisposableRepoProvider<ITestRepo>(
          create: (context) {
            createdRepo = NonDisposableRepo();
            return createdRepo;
          },
          child: Builder(
            builder: (context) {
              context.read<ITestRepo>();
              return const SizedBox();
            },
          ),
        ),
      );

      expect(createdRepo, isA<NonDisposableRepo>());

      await tester.pumpWidget(const SizedBox());
    });
  });
}
