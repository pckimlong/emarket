import 'package:auto_route/auto_route.dart';

import '../session_bloc.dart';
import 'app_router.gr.dart';

final class SplashGuard({required final SessionBloc _sessionBloc})
    extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    _sessionBloc.state.whenOrNull(
      unauthenticated: () => resolver.redirectUntil(LoginRoute()),
      shopRequired: () => resolver.redirectUntil(ShopSelectionRoute()),
      ready: (_) => resolver.next(),
    );
  }
}
