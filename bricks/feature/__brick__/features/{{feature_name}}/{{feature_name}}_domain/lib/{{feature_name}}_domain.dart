/// Domain layer for the {{feature_name}} feature.
library;

export 'package:domain_primitives/domain_primitives.dart'
    show {{class_name}}Id, Failure, Result;

export 'models/{{feature_name}}.dart';
export 'repositories/i_admin_{{feature_name}}_repo.dart';
export 'repositories/i_customer_{{feature_name}}_repo.dart';
