import 'package:admin/app/session_bloc.dart';
import 'package:app_bootstrap/app_bootstrap.dart';
import 'package:auth_data/auth_data.dart';
import 'package:catalog_data/catalog_data.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_data/media_data.dart';
import 'package:media_domain/media_domain.dart';
import 'package:shop_data/shop_data.dart';

/// Lazily creates shared infrastructure repositories and owns the application BLoC.
final class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.config,
    required this.talker,
    required this.authRepo,
    required this.child,
  });

  final BootstrapConfig config;
  final IAuthRepo authRepo;
  final Talker talker;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final client = context.read<Client>();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BootstrapConfig>.value(value: config),
        RepositoryProvider<Talker>.value(value: talker),
        RepositoryProvider<IAuthRepo>.value(value: authRepo),

        DisposableRepoProvider<IAdminShopRepo>(
          create: (_) => AdminShopRepoImpl(endpoint: client.adminShop),
        ),
      ],
      child: BlocProvider<SessionBloc>(
        create: (context) => SessionBloc(
          authRepo: context.read<IAuthRepo>(),
          adminShopRepo: context.read<IAdminShopRepo>(),
        ),
        child: child,
      ),
    );
  }
}

/// Scoped Composition Root for authenticated admin features.
///
/// Mounted in `MaterialApp.builder` so that it sits above the root [Navigator].
/// This ensures all routes, dialogs (`showDialog`, `showFDialog`), bottom sheets,
/// and overlays can access authenticated data repositories via context without
/// manual provider forwarding.
///
/// Owns the lifecycle of authenticated data repositories.
/// When the user logs out or switches the active shop, all
/// repositories are automatically disposed and in-memory caches are cleared.
final class AuthenticatedProviders extends StatelessWidget {
  const AuthenticatedProviders({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final client = context.read<Client>();
    final activeShopId = context.select<SessionBloc, ShopId?>(
      (e) => e.state.selectedShopId,
    );

    /// The key that trigger provider dispose. If need other condition consider add to the list
    final refresherKey = [
      activeShopId?.value ?? '<no-shop-selected>',
    ].join('-');

    return MultiRepositoryProvider(
      key: ValueKey(refresherKey),
      providers: [
        DisposableRepoProvider<IAdminBrandRepo>(
          create: (_) => AdminBrandRepoImpl(endpoint: client.adminBrand),
        ),
        DisposableRepoProvider<IMediaRepo>(
          create: (_) => MediaRepoImpl(endpoint: client.adminMedia),
        ),
      ],
      child: child,
    );
  }
}
