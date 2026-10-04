import 'package:admin/app/app_providers.dart';
import 'package:admin/app/app_splash.dart';
import 'package:admin/app/routing/app_router.dart';
import 'package:admin/app/routing/app_router_guard.dart';
import 'package:admin/app/session_bloc.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:material_ui/material_ui.dart' hide GlobalMaterialLocalizations;
import 'package:talker_flutter/talker_flutter.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late final Talker _talker;
  late final AppRouter _appRouter;
  late final ReevaluateListenable _sessionChange;
  late final SessionBloc _sessionBloc;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    _sessionBloc = context.read<SessionBloc>();
    _talker = context.read<Talker>();
    _appRouter = AppRouter(splashGuard: SplashGuard(sessionBloc: _sessionBloc));
    _sessionChange = ReevaluateListenable.stream(
      _sessionBloc.stream.map((e) => e.routingStatus).distinct(),
    );
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _appRouter.dispose();
      _sessionChange.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (
      lightTheme,
      darkTheme,
    ) = const <TargetPlatform>{
          .android,
          .iOS,
          .fuchsia,
        }.contains(defaultTargetPlatform)
        ? (getAdminLightTheme(touch: true), getAdminDarkTheme(touch: true))
        : (getAdminLightTheme(touch: false), getAdminDarkTheme(touch: false));

    final materialLightTheme = lightTheme.toApproximateMaterialTheme().copyWith(
      textTheme: lightTheme.toApproximateMaterialTheme().textTheme.apply(
        fontFamily: 'Geist',
      ),
    );
    final materialDarkTheme = darkTheme.toApproximateMaterialTheme().copyWith(
      textTheme: darkTheme.toApproximateMaterialTheme().textTheme.apply(
        fontFamily: 'Geist',
      ),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(
        reevaluateListenable: _sessionChange,
        placeholder: (context) => AppSplash(),
        navigatorObservers: () => [TalkerRouteObserver(_talker)],
      ),
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [
        ...FLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: materialLightTheme,
      darkTheme: materialDarkTheme,
      themeMode: .light,
      builder: (context, child) {
        return AuthenticatedProviders(
          child: FTheme(
            data: Theme.brightnessOf(context) == .light
                ? lightTheme
                : darkTheme,
            child: FToaster(child: FTooltipGroup(child: child!)),
          ),
        );
      },
    );
  }
}
