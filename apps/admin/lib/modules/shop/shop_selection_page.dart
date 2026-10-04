import 'package:admin/app/session_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_admin_presentation/shop_list/view/shop_selection_module.dart';
import 'package:shop_domain/shop_domain.dart';

@RoutePage()
class ShopSelectionPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<IAdminShopRepo>();
    final selectedShopId = context.select<SessionBloc, ShopId?>(
      (value) => value.state.selectedShopId,
    );

    return Scaffold(
      body: ShopSelectionModule(
        shopRepo: repo,
        selectedShopId: selectedShopId,
        onShopSelected: (value) {
          context.read<SessionBloc>().add(SessionShopSelected(value.id));
        },
      ),
    );
  }
}
