import 'dart:async';

import 'package:auth_domain/auth_domain.dart';
import 'package:data_utils/data_utils.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

final class AuthRepoImpl implements IAuthRepo, Disposable {
  AuthRepoImpl({
    required this.client,
    required this.sessionManager,
  });

  final Client client;
  final ClientAuthSessionManager sessionManager;
  final _authStateController = StreamController<AuthState>.broadcast();

  @override
  AuthId? get currentAuthId {
    final authUserId = sessionManager.authInfo?.authUserId;
    if (authUserId == null) return null;
    return AuthId(authUserId.uuid);
  }

  @override
  AuthState get currentAuthState {
    final authId = currentAuthId;
    if (authId == null) {
      return const AuthState.unauthenticated();
    }
    return AuthState.authenticated(authId);
  }

  @override
  Stream<AuthState> get authState async* {
    yield currentAuthState;
    yield* _authStateController.stream;
  }

  @override
  Result<AuthId> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return failureHandler(() async {
      final result = await client.emailIdp.login(
        email: email,
        password: password,
      );
      await sessionManager.updateSignedInUser(result);
      final authId = AuthId(result.authUserId.uuid);
      _authStateController.add(AuthState.authenticated(authId));
      return authId;
    });
  }

  @override
  Result<void> signOut() {
    return failureHandler(() async {
      await sessionManager.signOutDevice();
      _authStateController.add(const AuthState.unauthenticated());
    });
  }

  @override
  void dispose() {
    _authStateController.close();
  }
}
