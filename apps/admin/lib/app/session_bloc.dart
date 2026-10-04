import 'package:auth_domain/auth_domain.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shop_domain/shop_domain.dart';

part 'session_bloc.freezed.dart';

@freezed
abstract class SessionState with _$SessionState {
  const SessionState._();

  const factory SessionState.loading() = SessionLoading;
  const factory SessionState.unauthenticated() = SessionUnauthenticated;
  const factory SessionState.shopRequired() = SessionShopRequired;
  const factory SessionState.ready(ActiveShopContext activeShop) = SessionReady;
  const factory SessionState.error(Failure failure) = SessionFailure;

  ShopId? get selectedShopId => switch (this) {
    SessionReady(:final activeShop) => activeShop.shopId,
    _ => null,
  };
}

sealed class const SessionEvent();
final class const SessionStarted() extends SessionEvent;
final class const SessionShopSelected(final ShopId shopId) extends SessionEvent;
final class const SessionAuthStateChanged(final AuthState authState)
    extends SessionEvent;
final class const SessionAuthStreamFailed(final Object error)
    extends SessionEvent;

final class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final IAuthRepo _authRepo;
  final IAdminShopRepo _adminShopRepo;

  SessionBloc({required this._authRepo, required this._adminShopRepo})
    : super(const SessionState.loading()) {
    on<SessionStarted>(_onStarted, transformer: restartable());
    on<SessionAuthStateChanged>(
      _onAuthStateChanged,
      transformer: restartable(),
    );
    on<SessionShopSelected>(_onShopSelected, transformer: restartable());
    on<SessionAuthStreamFailed>(
      (event, emit) => emit(
        SessionState.error(
          Failure(error: event.error, stackTrace: StackTrace.current),
        ),
      ),
      transformer: restartable(),
    );

    add(const SessionStarted());
  }

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    if (state is! SessionLoading) {
      emit(const SessionState.loading());
    }

    await emit.onEach<AuthState>(
      _authRepo.authState.distinct(),
      onData: (authState) => add(SessionAuthStateChanged(authState)),
      onError: (error, stackTrace) => add(SessionAuthStreamFailed(error)),
    );
  }

  Future<void> _onAuthStateChanged(
    SessionAuthStateChanged event,
    Emitter<SessionState> emit,
  ) async {
    final authState = event.authState;
    if (authState.isInitial) {
      emit(const SessionState.loading());
      return;
    }

    if (!authState.isAuthenticated) {
      emit(const SessionState.unauthenticated());
      return;
    }

    // Authentication is valid, but the admin application is not ready
    // until a working shop can also be established.
    emit(const SessionState.loading());

    final result = await _adminShopRepo.getActiveShop().run();

    result.match(
      (failure) => emit(SessionState.error(failure)),
      (activeShop) => activeShop.match(
        () => emit(const SessionState.shopRequired()),
        (shopContext) => emit(SessionState.ready(shopContext)),
      ),
    );
  }

  Future<void> _onShopSelected(
    SessionShopSelected event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionState.loading());

    final result = await _adminShopRepo.setActiveShop(event.shopId).run();

    result.match(
      (failure) => emit(SessionState.error(failure)),
      (activeShop) => emit(SessionState.ready(activeShop)),
    );
  }
}

enum SessionRoutingStatus {
  loading,
  unauthenticated,
  shopRequired,
  ready,
  failure,
}

extension SessionStateX on SessionState {
  SessionRoutingStatus get routingStatus => switch (this) {
    SessionLoading() => .loading,
    SessionUnauthenticated() => .unauthenticated,
    SessionShopRequired() => .shopRequired,
    SessionReady() => .ready,
    SessionFailure() => .failure,
    SessionState() => throw UnimplementedError(),
  };
}
