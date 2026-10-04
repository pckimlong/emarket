import 'package:presentation_utils/presentation_utils.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:shop_domain/shop_domain.dart';

class ShopListCubit({
  required final IAdminShopRepo _shopRepo,
}) extends AsyncCubit<IList<Shop>> {
  Future<void> load() async {
    await emitEitherGuard(_shopRepo.listAccessibleShops().run);
  }
}
