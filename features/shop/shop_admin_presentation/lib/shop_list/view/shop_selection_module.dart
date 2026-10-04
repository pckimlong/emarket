import 'package:presentation_utils/presentation_utils.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_admin_presentation/shop_list/cubit/shop_list_cubit.dart';
import 'package:shop_domain/shop_domain.dart';

class ShopSelectionModule extends StatelessWidget {
  const new({
    super.key,
    required this.shopRepo,
    this.selectedShopId,
    this.onShopSelected,
  });

  final IAdminShopRepo shopRepo;
  final ShopId? selectedShopId;
  final ValueChanged<Shop>? onShopSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShopListCubit(shopRepo: shopRepo)..load(),
      child: BlocBuilder<ShopListCubit, AsyncState<IList<Shop>>>(
        builder: (context, state) {
          return state.when(
            loading: (_) => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(error.toDebugString()),
            data: (shops) => ListView.builder(
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                return ListTile(
                  selected: shop.id == selectedShopId,
                  onTap: onShopSelected == null
                      ? null
                      : () => onShopSelected!.call(shop),
                  title: Text(shops[index].name),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
