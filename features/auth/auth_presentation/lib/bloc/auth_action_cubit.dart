import 'package:auth_domain/auth_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthActionStatus { initial, submitting, success, failure }

/// Handles route-owned authentication commands; the repository remains the
/// shared source of session state for routing and the application BLoC.
final class AuthActionCubit extends Cubit<AuthActionStatus> {
  AuthActionCubit(this._authRepo) : super(AuthActionStatus.initial);

  final IAuthRepo _authRepo;

  Future<bool> signIn({required String email, required String password}) =>
      _submit(
        () => _authRepo.signInWithEmailPassword(
          email: email.trim(),
          password: password,
        ),
      );

  Future<bool> signOut() => _submit(_authRepo.signOut);

  Future<bool> _submit<T>(Result<T> Function() action) async {
    if (isClosed || state == AuthActionStatus.submitting) return false;
    emit(AuthActionStatus.submitting);
    final result = await action().run();
    return result.fold(
      (_) {
        if (!isClosed) emit(AuthActionStatus.failure);
        return false;
      },
      (_) {
        if (!isClosed) emit(AuthActionStatus.success);
        return true;
      },
    );
  }
}
