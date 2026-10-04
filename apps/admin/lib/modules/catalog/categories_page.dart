import 'package:admin/shared/widgets/admin_page_shell.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPageShell(
      title: 'Categories',
      icon: LucideIcons.shapes,
      description: 'Manage product categories and category hierarchy.',
    );
  }
}
