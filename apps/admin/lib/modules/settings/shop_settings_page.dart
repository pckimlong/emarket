import 'package:admin/shared/widgets/admin_page_shell.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ShopSettingsPage extends StatelessWidget {
  const ShopSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPageShell(
      title: 'Shop settings',
      icon: LucideIcons.settings,
      description: 'Configure store profile, currency, taxes, payments, and shipping policies.',
    );
  }
}
