/// Domain layer for the customer feature.
library;

export 'package:domain_primitives/domain_primitives.dart'
    show CustomerId, Failure, Result;

export 'models/customer.dart';
export 'repositories/i_admin_customer_repo.dart';
export 'repositories/i_customer_profile_repo.dart';
