import 'package:fpdart/fpdart.dart';

import 'failure.dart';

/// Result type for domain operations
typedef Result<T> = TaskEither<Failure, T>;
