import 'dart:async';

import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakeAuthRepo implements IAuthRepo {
  int calls = 0;
  String? email;
  bool fail = false;
  Completer<void>? pending;

  @override
  Result<AuthId> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return TaskEither(() async {
      this.email = email;
      await signOut().run();
      return const Right(AuthId('test'));
    });
  }

  @override
  Result<void> signOut() {
    return TaskEither(() async {
      calls++;
      if (fail) {
        return Left(
          Failure(error: StateError('offline'), stackTrace: StackTrace.empty),
        );
      }
      await pending?.future;
      return const Right(null);
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeAuthRepo repo;
  setUp(() => repo = FakeAuthRepo());

  blocTest<AuthActionCubit, AuthActionStatus>(
    'signs in with trimmed email and emits success',
    build: () => AuthActionCubit(repo),
    act: (cubit) => cubit.signIn(email: ' a@b.com ', password: 'password'),
    expect: () => [AuthActionStatus.submitting, AuthActionStatus.success],
    verify: (_) => expect(repo.email, 'a@b.com'),
  );

  blocTest<AuthActionCubit, AuthActionStatus>(
    'sign-out failure can be retried',
    build: () => AuthActionCubit(repo),
    act: (cubit) async {
      repo.fail = true;
      expect(await cubit.signOut(), isFalse);
      repo.fail = false;
      expect(await cubit.signOut(), isTrue);
    },
    expect: () => [
      AuthActionStatus.submitting,
      AuthActionStatus.failure,
      AuthActionStatus.submitting,
      AuthActionStatus.success,
    ],
  );

  test(
    'ignores overlapping submissions and tolerates disposal during a request',
    () async {
      repo.pending = Completer<void>();
      final cubit = AuthActionCubit(repo);
      final first = cubit.signOut();
      expect(await cubit.signOut(), isFalse);
      expect(repo.calls, 1);
      await cubit.close();
      repo.pending!.complete();
      expect(await first, isTrue);
    },
  );
}
