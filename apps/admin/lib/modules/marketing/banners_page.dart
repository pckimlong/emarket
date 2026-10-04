import 'package:admin/shared/widgets/admin_page_shell.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class BannersPage extends StatelessWidget {
  const BannersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPageShell(
      title: 'Banners',
      icon: LucideIcons.image,
      description: 'Manage homepage banners, promotional carousels, and ads.',
    );
  }
}
