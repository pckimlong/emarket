import 'package:admin/app/root_page.dart';
import 'package:admin/shared/utils/navigation_mode.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:flutter/material.dart';

class AdminPageShell extends StatelessWidget {
  const AdminPageShell({
    required this.title,
    this.icon,
    this.description,
    this.actions,
    this.child,
    super.key,
  });

  final IconData? icon;
  final String title;
  final String? description;
  final List<Widget>? actions;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDrawer = context.isNavigationDrawer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              if (isDrawer)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FHeaderAction(
                    icon: const Icon(LucideIcons.panel_left),
                    onPress: () => RootPage.maybeOf(context)?.openDrawer(),
                  ),
                ),
              Expanded(
                child: Text(
                  title,
                  style: context.theme.typography.display.md.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (actions != null) ...?actions,
            ],
          ),
        ),
        Expanded(
          child:
              child ??
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.theme.colors.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                size: 32,
                                color: context.theme.colors.primary,
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: context.theme.typography.display.sm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description ?? 'This page is a placeholder. Feature module will be injected here.',
                            style: context.theme.typography.body.sm.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
