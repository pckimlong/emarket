import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:catalog_admin_presentation/brand/list/bloc/brand_list_bloc.dart';
import 'package:catalog_admin_presentation/brand/list/bloc/brand_list_event.dart';
import 'package:catalog_admin_presentation/brand/list/bloc/brand_list_state.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation_utils/presentation_utils.dart';

class BrandListModule extends StatelessWidget {
  const BrandListModule({
    super.key,
    required this.brandRepo,
    this.onBrandTapped,
    this.initialActiveFilter,
    this.builder,
  });

  final IAdminBrandRepo brandRepo;
  final ValueChanged<Brand>? onBrandTapped;
  final bool? initialActiveFilter;

  /// Optionally wraps the brand list with access to its provider-owned bloc.
  ///
  /// Use this to compose page-level UI such as a shell or toolbar actions. Wrap
  /// state-dependent actions in a [BlocBuilder] or [BlocSelector].
  final BlocModuleBuilder<BrandListBloc>? builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BrandListBloc(
        brandRepo: brandRepo,
        initialActiveFilter: initialActiveFilter,
      ),
      child: BlocModuleHost<BrandListBloc>(
        builder: builder,
        content: _BrandListView(onBrandTapped: onBrandTapped),
      ),
    );
  }
}

class _BrandListView extends StatelessWidget {
  const _BrandListView({
    this.onBrandTapped,
  });

  final ValueChanged<Brand>? onBrandTapped;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandListBloc, BrandListState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildControls(context, state),
            const SizedBox(height: 16),
            Expanded(
              child: _buildContent(context, state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls(BuildContext context, BrandListState state) {
    return Row(
      children: [
        Expanded(
          child: FTextField(
            control: FTextFieldControl.managed(
              onChange: (value) => context.read<BrandListBloc>().add(
                BrandListSearchChanged(value.text),
              ),
            ),
            hint: 'Search brands by name...',
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const Icon(LucideIcons.search, size: 16),
                ),
          ),
        ),
        const SizedBox(width: 12),
        _buildFilterButton(
          label: 'All',
          isSelected: state.activeFilter == null,
          onPress: () => context.read<BrandListBloc>().add(
            const BrandListFilterChanged(isActive: null),
          ),
        ),
        const SizedBox(width: 6),
        _buildFilterButton(
          label: 'Active',
          isSelected: state.activeFilter == true,
          onPress: () => context.read<BrandListBloc>().add(
            const BrandListFilterChanged(isActive: true),
          ),
        ),
        const SizedBox(width: 6),
        _buildFilterButton(
          label: 'Inactive',
          isSelected: state.activeFilter == false,
          onPress: () => context.read<BrandListBloc>().add(
            const BrandListFilterChanged(isActive: false),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPress,
  }) {
    return FButton(
      variant: isSelected ? .primary : .outline,
      onPress: onPress,
      child: Text(label),
    );
  }

  Widget _buildContent(BuildContext context, BrandListState state) {
    final allBrands = state.allBrands;

    if (allBrands is AsyncLoadingState && allBrands.valueOrNull == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allBrands is AsyncFailureState<IList<Brand>> &&
        allBrands.valueOrNull == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.circle_alert,
              size: 40,
              color: context.theme.colors.destructive,
            ),
            const SizedBox(height: 12),
            Text(
              allBrands.failure.displayMessage,
              style: context.theme.typography.body.md.copyWith(
                color: context.theme.colors.destructive,
              ),
            ),
            const SizedBox(height: 16),
            FButton(
              onPress: () =>
                  context.read<BrandListBloc>().add(const BrandListStarted()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final brands = state.brands;
    if (brands.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.tag,
                size: 48,
                color: context.theme.colors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                'No brands found',
                style: context.theme.typography.display.sm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'No brands match your search query or filter criteria.',
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AdminDataTable<Brand>(
      items: brands,
      onRowTap: onBrandTapped,
      columns: [
        DataColumnDef(
          header: 'LOGO',
          width: 64,
          cellBuilder: (context, brand) {
            final logoUrl = brand.logoUri.toString();
            return Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.theme.colors.secondary,
                borderRadius: context.theme.style.borderRadius.sm,
                border: Border.all(
                  color: context.theme.colors.border,
                  width: context.theme.style.borderWidth,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(
                          LucideIcons.image,
                          size: 16,
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        LucideIcons.image,
                        size: 16,
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
            );
          },
        ),
        DataColumnDef(
          header: 'NAME',
          flex: 6,
          sortValue: (brand) => brand.name,
          cellBuilder: (context, brand) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                brand.name,
                style: context.theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'ID: ${brand.id.value}',
                style: context.theme.typography.body.xs.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        DataColumnDef(
          header: 'STATUS',
          width: 120,
          alignment: Alignment.center,
          sortValue: (brand) => brand.isActive ? 1 : 0,
          cellBuilder: (context, brand) => FBadge(
            variant: brand.isActive ? .primary : .secondary,
            child: Text(brand.isActive ? 'Active' : 'Inactive'),
          ),
        ),
      ],
      mobileItemBuilder: (context, brand) => _BrandListItem(
        brand: brand,
        onTap: () => onBrandTapped?.call(brand),
      ),
    );
  }
}

class _BrandListItem extends StatelessWidget {
  const _BrandListItem({
    required this.brand,
    this.onTap,
  });

  final Brand brand;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: onTap,
      builder: (context, _, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.theme.colors.card,
          borderRadius: context.theme.style.borderRadius.md,
          border: Border.all(
            color: context.theme.colors.border,
            width: context.theme.style.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.theme.colors.secondary,
                borderRadius: context.theme.style.borderRadius.md,
                border: Border.all(
                  color: context.theme.colors.border,
                  width: context.theme.style.borderWidth,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: brand.logoUri.toString().isNotEmpty
                  ? Image.network(
                      brand.logoUri.toString(),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(
                          LucideIcons.image,
                          size: 20,
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        LucideIcons.image,
                        size: 20,
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    brand.name,
                    style: context.theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${brand.id.value}',
                    style: context.theme.typography.body.xs.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            FBadge(
              variant: brand.isActive ? .primary : .secondary,
              child: Text(brand.isActive ? 'Active' : 'Inactive'),
            ),
            const SizedBox(width: 12),
            Icon(
              LucideIcons.chevron_right,
              size: 16,
              color: context.theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
