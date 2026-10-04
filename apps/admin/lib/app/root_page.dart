import 'package:admin/app/routing/app_router.gr.dart';
import 'package:admin/shared/utils/navigation_mode.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  RootPageState createState() => RootPageState();

  static RootPageState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<RootPageState>();
  }

  static RootPageState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'No RootPageState found in context');
    return state!;
  }
}

class RootPageState extends State<RootPage> {
  late TabsRouter _tabsRouter;
  String _selectedShop = 'Main Store';

  final List<String> _shops = [
    'Main Store',
    'Downtown Branch',
    'Warehouse Direct',
  ];

  void openDrawer() {
    showFSheet(
      context: context,
      side: .ltr,
      builder: (sheetContext) => DecoratedBox(
        decoration: BoxDecoration(color: sheetContext.theme.colors.background),
        child: _buildSidebar(sheetContext, isDrawer: true),
      ),
    );
  }

  void _handleTabPress(int index, {required bool isDrawer}) {
    if (_tabsRouter.activeIndex == index) {
      final stackRouter = _tabsRouter.stackRouterOfIndex(index);
      if (stackRouter != null && stackRouter.canPop()) {
        stackRouter.popUntilRoot();
      }
    } else {
      _tabsRouter.setActiveIndex(index);
    }
    if (isDrawer) {
      Navigator.of(context).pop();
    }
  }

  void _showShopSelector(BuildContext context) {
    showFDialog(
      context: context,
      builder: (dialogContext, dialogStyle, animation) => FDialog(
        animation: animation,
        builder: (ctx, style) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Shop',
                style: ctx.theme.typography.display.sm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._shops.map((shop) {
                final isSelected = shop == _selectedShop;
                return FTappable(
                  onPress: () {
                    setState(() => _selectedShop = shop);
                    Navigator.of(dialogContext).pop();
                  },
                  builder: (_, variants, _) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ctx.theme.colors.secondary
                          : Colors.transparent,
                      borderRadius: ctx.theme.style.borderRadius.md,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.store,
                          size: 18,
                          color: isSelected
                              ? ctx.theme.colors.primary
                              : ctx.theme.colors.mutedForeground,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            shop,
                            style: ctx.theme.typography.body.sm.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            LucideIcons.check,
                            size: 16,
                            color: ctx.theme.colors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              FButton(
                variant: .secondary,
                onPress: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool isDrawer}) {
    final isCollapsed =
        !isDrawer && (context.navigationMode == AppNavigationMode.collapsed);
    final activeIndex = _tabsRouter.activeIndex;

    return FSidebar(
      style: isDrawer
          ? const FSidebarStyleDelta.delta(
              constraints: BoxConstraints(minWidth: 280, maxWidth: 280),
            )
          : isCollapsed
          ? const FSidebarStyleDelta.delta(
              constraints: BoxConstraints.tightFor(width: 72),
            )
          : const FSidebarStyleDelta.delta(
              constraints: BoxConstraints(minWidth: 260, maxWidth: 260),
            ),
      header: isCollapsed
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Tooltip(
                message: 'E-Market - $_selectedShop',
                child: Icon(
                  LucideIcons.store,
                  size: 24,
                  color: context.theme.colors.primary,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.shopping_bag,
                          size: 22,
                          color: context.theme.colors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'E-Market',
                          style: context.theme.typography.display.md.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FTappable(
                    onPress: () => _showShopSelector(context),
                    builder: (_, variants, _) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.theme.colors.secondary,
                        borderRadius: context.theme.style.borderRadius.md,
                        border: Border.all(
                          color: context.theme.colors.border,
                          width: context.theme.style.borderWidth,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.store,
                            size: 16,
                            color: context.theme.colors.mutedForeground,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedShop,
                              style: context.theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            LucideIcons.chevrons_up_down,
                            size: 14,
                            color: context.theme.colors.mutedForeground,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const FDivider(
                    style: .delta(padding: .value(EdgeInsets.zero)),
                  ),
                ],
              ),
            ),
      footer: isCollapsed
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Tooltip(
                message: 'Sign out',
                child: FTappable(
                  onPress: () async {
                    final authRepo = context.read<IAuthRepo>();
                    await authRepo.signOut().run();
                  },
                  builder: (_, variants, _) => FAvatar.raw(
                    child: Icon(
                      LucideIcons.user_round,
                      size: 18,
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      FAvatar.raw(
                        child: Icon(
                          LucideIcons.user_round,
                          size: 18,
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Admin User',
                              style: context.theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.theme.colors.foreground,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'admin@emarket.local',
                              style: context.theme.typography.body.xs.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: 'Sign out',
                        child: FTappable(
                          onPress: () async {
                            final authRepo = context.read<IAuthRepo>();
                            await authRepo.signOut().run();
                          },
                          builder: (_, variants, _) => Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              LucideIcons.log_out,
                              size: 16,
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      children: [
        FSidebarGroup(
          children: [
            // Overview
            FSidebarItem(
              icon: const Icon(LucideIcons.layout_dashboard),
              label: isCollapsed ? null : const Text('Overview'),
              selected: activeIndex == 0,
              onPress: () => _handleTabPress(0, isDrawer: isDrawer),
            ),
            // Orders
            FSidebarItem(
              icon: const Icon(LucideIcons.shopping_bag),
              label: isCollapsed ? null : const Text('Orders'),
              selected: activeIndex == 1,
              onPress: () => _handleTabPress(1, isDrawer: isDrawer),
            ),
            // Catalog (Products, Categories, Brands)
            if (isCollapsed)
              FSidebarItem(
                icon: const Icon(LucideIcons.boxes),
                selected: activeIndex >= 2 && activeIndex <= 4,
                onPress: () => _handleTabPress(2, isDrawer: isDrawer),
              )
            else
              FSidebarItem(
                icon: const Icon(LucideIcons.box),
                label: const Text('Catalog'),
                selected: activeIndex >= 2 && activeIndex <= 4,
                initiallyExpanded: activeIndex >= 2 && activeIndex <= 4,
                children: [
                  FSidebarItem(
                    label: const Text('Products'),
                    selected: activeIndex == 2,
                    onPress: () => _handleTabPress(2, isDrawer: isDrawer),
                  ),
                  FSidebarItem(
                    label: const Text('Categories'),
                    selected: activeIndex == 3,
                    onPress: () => _handleTabPress(3, isDrawer: isDrawer),
                  ),
                  FSidebarItem(
                    label: const Text('Brands'),
                    selected: activeIndex == 4,
                    onPress: () => _handleTabPress(4, isDrawer: isDrawer),
                  ),
                ],
              ),
            // Inventory
            FSidebarItem(
              icon: const Icon(LucideIcons.warehouse),
              label: isCollapsed ? null : const Text('Inventory'),
              selected: activeIndex == 5,
              onPress: () => _handleTabPress(5, isDrawer: isDrawer),
            ),
            // Customers
            FSidebarItem(
              icon: const Icon(LucideIcons.users),
              label: isCollapsed ? null : const Text('Customers'),
              selected: activeIndex == 6,
              onPress: () => _handleTabPress(6, isDrawer: isDrawer),
            ),
            // Marketing (Promotions, Banners)
            if (isCollapsed)
              FSidebarItem(
                icon: const Icon(LucideIcons.megaphone),
                selected: activeIndex >= 7 && activeIndex <= 8,
                onPress: () => _handleTabPress(7, isDrawer: isDrawer),
              )
            else
              FSidebarItem(
                icon: const Icon(LucideIcons.megaphone),
                label: const Text('Marketing'),
                selected: activeIndex >= 7 && activeIndex <= 8,
                initiallyExpanded: activeIndex >= 7 && activeIndex <= 8,
                children: [
                  FSidebarItem(
                    label: const Text('Promotions'),
                    selected: activeIndex == 7,
                    onPress: () => _handleTabPress(7, isDrawer: isDrawer),
                  ),
                  FSidebarItem(
                    label: const Text('Banners'),
                    selected: activeIndex == 8,
                    onPress: () => _handleTabPress(8, isDrawer: isDrawer),
                  ),
                ],
              ),
            // Reports
            FSidebarItem(
              icon: const Icon(LucideIcons.chart_bar),
              label: isCollapsed ? null : const Text('Reports'),
              selected: activeIndex == 9,
              onPress: () => _handleTabPress(9, isDrawer: isDrawer),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: FDivider(style: .delta(padding: .value(EdgeInsets.zero))),
            ),

            // Team
            FSidebarItem(
              icon: const Icon(LucideIcons.user_check),
              label: isCollapsed ? null : const Text('Team'),
              selected: activeIndex == 10,
              onPress: () => _handleTabPress(10, isDrawer: isDrawer),
            ),
            // Shop settings
            FSidebarItem(
              icon: const Icon(LucideIcons.settings),
              label: isCollapsed ? null : const Text('Shop settings'),
              selected: activeIndex == 11,
              onPress: () => _handleTabPress(11, isDrawer: isDrawer),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationMode = context.resolveNavigationMode;

    return AppNavigationModeScope(
      mode: navigationMode,
      child: AutoTabsRouter(
        routes: const [
          OverviewRoute(),
          OrdersRoute(),
          ProductsRoute(),
          CategoriesRoute(),
          BrandListRoute(),
          InventoryRoute(),
          CustomersRoute(),
          PromotionsRoute(),
          BannersRoute(),
          ReportsRoute(),
          TeamRoute(),
          ShopSettingsRoute(),
        ],
        builder: (context, child) {
          _tabsRouter = AutoTabsRouter.of(context);

          return FScaffold(
            sidebar: navigationMode == AppNavigationMode.drawer
                ? null
                : _buildSidebar(context, isDrawer: false),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              primary: false,
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(
                    navigationMode == AppNavigationMode.drawer ? 12 : 20,
                  ),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
