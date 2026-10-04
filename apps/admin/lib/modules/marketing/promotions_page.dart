import 'package:admin/shared/widgets/admin_page_shell.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPageShell(
      title: 'Promotions',
      icon: LucideIcons.sparkles,
      description: 'Create discount codes, flash sales, and campaign rules.',
    );
  }
}
