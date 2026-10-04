import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';
import 'app_router_guard.dart';

@AutoRouterConfig(deferredLoading: true)
final class AppRouter extends RootStackRouter {
  AppRouter({required this.splashGuard});

  final SplashGuard splashGuard;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(
      page: RootRoute.page,
      path: '/',
      initial: true,
      guards: [splashGuard],
      children: [
        AutoRoute(page: OverviewRoute.page, path: 'overview', initial: true),
        AutoRoute(page: OrdersRoute.page, path: 'orders'),
        AutoRoute(page: ProductsRoute.page, path: 'catalog/products'),
        AutoRoute(page: CategoriesRoute.page, path: 'catalog/categories'),
        AutoRoute(page: BrandListRoute.page, path: 'catalog/brands'),
        AutoRoute(page: InventoryRoute.page, path: 'inventory'),
        AutoRoute(page: CustomersRoute.page, path: 'customers'),
        AutoRoute(page: PromotionsRoute.page, path: 'marketing/promotions'),
        AutoRoute(page: BannersRoute.page, path: 'marketing/banners'),
        AutoRoute(page: ReportsRoute.page, path: 'reports'),
        AutoRoute(page: TeamRoute.page, path: 'team'),
        AutoRoute(page: ShopSettingsRoute.page, path: 'settings'),
      ],
    ),
    AutoRoute(page: ShopSelectionRoute.page, path: '/select-shops'),
    AutoRoute(page: TalkerRoute.page, path: '/talker'),
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
