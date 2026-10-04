/// Domain layer for the shop feature.
library;

export 'package:domain_primitives/domain_primitives.dart'
    show ShopId, Failure, Result;

export 'models/models.dart';
export 'repositories/i_admin_shop_repo.dart';
export 'repositories/i_customer_shop_repo.dart';
