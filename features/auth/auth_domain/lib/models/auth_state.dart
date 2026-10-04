import 'package:domain_primitives/domain_primitives.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.authenticated(AuthId authId) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  bool get isAuthenticated => this is AuthStateAuthenticated;
  bool get isInitial => this is AuthStateInitial;

  AuthId? get authIdOrNull => switch (this) {
    AuthStateAuthenticated(:final authId) => authId,
    _ => null,
  };
}
