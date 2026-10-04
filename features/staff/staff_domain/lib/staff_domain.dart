/// Domain layer for the staff feature.
library;

export 'package:domain_primitives/domain_primitives.dart'
    show StaffId, AuthId, Failure, Result;

export 'models/staff.dart';
export 'repositories/i_staff_repo.dart';
