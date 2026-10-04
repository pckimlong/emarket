import 'dart:async';

import 'package:app_bootstrap/src/guarded_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startup executes in one child zone and completes', () async {
    final parent = Zone.current;
    await runGuardedBootstrap(() async {
      final startupZone = Zone.current;
      expect(startupZone, isNot(same(parent)));
      await Future<void>.delayed(Duration.zero);
      expect(Zone.current, same(startupZone));
    }, reportError: (_, _) => fail('Unexpected uncaught error'));
  });

  for (final asynchronous in [false, true]) {
    test(
      'caller receives ${asynchronous ? 'async' : 'sync'} startup failure',
      () async {
        final error = StateError('startup failed');
        await expectLater(
          runGuardedBootstrap(
            () {
              if (asynchronous) return Future<void>.error(error);
              throw error;
            },
            reportError: (_, _) => fail('Awaited error must reach the caller'),
          ),
          throwsA(same(error)),
        );
      },
    );
  }

  test(
    'detached startup failure completes the caller and reports later failure',
    () async {
      final release = Completer<void>();
      final reported = <Object>[];
      final first = StateError('detached');
      final second = StateError('later startup failure');
      final laterReported = Completer<void>();
      final startup = runGuardedBootstrap(
        () async {
          scheduleMicrotask(() => throw first);
          await release.future;
          throw second;
        },
        reportError: (error, _) {
          reported.add(error);
          if (identical(error, second)) laterReported.complete();
        },
      );
      await expectLater(startup, throwsA(same(first)));
      release.complete();
      await laterReported.future;
      expect(reported, [first, second]);
    },
  );

  test('reports detached runtime errors after startup completes', () async {
    final reported = Completer<Object>();
    final trigger = Completer<void>();
    final error = StateError('runtime failed');
    await runGuardedBootstrap(() {
      unawaited(trigger.future.then<void>((_) => throw error));
    }, reportError: (error, _) => reported.complete(error));
    trigger.complete();
    expect(await reported.future, same(error));
  });
}
