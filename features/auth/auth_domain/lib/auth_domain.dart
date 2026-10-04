/// Domain layer for the auth feature.
library;

export 'package:domain_primitives/domain_primitives.dart'
    show AuthId, Failure, Result;

export 'models/auth_state.dart';
export 'repositories/i_auth_repo.dart';
