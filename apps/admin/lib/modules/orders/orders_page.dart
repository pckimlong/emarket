import 'package:admin/shared/widgets/admin_page_shell.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPageShell(
      title: 'Orders',
      icon: LucideIcons.shopping_bag,
      description: 'Manage customer orders, fulfillments, and returns.',
    );
  }
}
