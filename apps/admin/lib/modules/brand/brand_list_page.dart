import 'package:admin/shared/widgets/admin_page_shell.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:catalog_admin_presentation/catalog_admin_presentation.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class BrandListPage extends StatelessWidget {
  const BrandListPage({super.key});

  void _openBrandForm(BuildContext context, {Brand? brand}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: context.theme.colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: context.theme.style.borderRadius.lg,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: BrandFormModule(
              brandRepo: context.read<IAdminBrandRepo>(),
              brandId: brand?.id,
              onSaved: (_) {
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BrandListModule(
      brandRepo: context.read<IAdminBrandRepo>(),
      onBrandTapped: (brand) => _openBrandForm(context, brand: brand),
      initialActiveFilter: null,
      builder: (context, bloc, content) {
        return AdminPageShell(
          title: 'Brands',
          icon: LucideIcons.tag,
          description: 'Manage brand catalog and manufacturer logos.',
          actions: [
            FRefreshButton(
              isLoading: false,
              onPress: () {
                bloc.add(const BrandListRefreshed());
              },
            ),
            SizedBox(width: 4),
            FButton(
              prefix: const Icon(LucideIcons.plus, size: 16),
              onPress: () => _openBrandForm(context),
              child: const Text('Add Brand'),
            ),
          ],
          child: content,
        );
      },
    );
  }
}
