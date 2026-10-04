import 'package:auth_domain/auth_domain.dart';

abstract class IAuthRepo {
  AuthId? get currentAuthId;
  AuthState get currentAuthState;
  Stream<AuthState> get authState;

  Result<AuthId> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Result<void> signOut();

  /// Releases resources owned by this repository. Does not sign the user out
  /// or dispose borrowed infrastructure such as the API client.
  void dispose();
}
