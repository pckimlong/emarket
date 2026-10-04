import 'package:admin/shared/widgets/admin_page_shell.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPageShell(
      title: 'Overview',
      icon: LucideIcons.layout_dashboard,
      description: 'E-Market performance metrics and overview dashboard.',
    );
  }
}
