import 'dart:async';

import 'package:auth_domain/auth_domain.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdart/fpdart.dart';

class FakeAuthRepo implements IAuthRepo {
  int disposeCalls = 0;

  @override
  void dispose() {
    disposeCalls++;
    _controller.close();
  }

  final _controller = StreamController<AuthState>.broadcast();
  AuthState _currentAuthState = const AuthState.initial();

  @override
  AuthId? get currentAuthId => switch (_currentAuthState) {
    AuthStateAuthenticated(:final authId) => authId,
    _ => null,
  };

  @override
  AuthState get currentAuthState => _currentAuthState;

  @override
  Stream<AuthState> get authState async* {
    yield _currentAuthState;
    yield* _controller.stream;
  }

  void fail(Object error) => _controller.addError(error);

  void emit(AuthState state) {
    _currentAuthState = state;
    _controller.add(state);
  }

  @override
  Result<AuthId> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return TaskEither(() async {
      const id = AuthId('user-123');
      emit(const AuthState.authenticated(id));
      return const Right(id);
    });
  }

  @override
  Result<void> signOut() {
    return TaskEither(() async {
      emit(const AuthState.unauthenticated());
      return const Right(null);
    });
  }
}

class FakeBrandRepo implements IAdminBrandRepo {
  final StreamController<IList<Brand>> _controller =
      StreamController<IList<Brand>>.broadcast();
  IList<Brand> _currentBrands = const IListConst([]);

  void emitBrands(IList<Brand> brands) {
    _currentBrands = brands;
    _controller.add(brands);
  }

  @override
  Stream<IList<Brand>> watchBrands() async* {
    yield _currentBrands;
    yield* _controller.stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
