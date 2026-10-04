import 'package:admin/shared/widgets/admin_page_shell.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPageShell(
      title: 'Customers',
      icon: LucideIcons.users,
      description: 'View customer accounts, purchase history, and segments.',
    );
  }
}
