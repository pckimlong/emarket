import 'package:domain_primitives/domain_primitives.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';

@freezed
abstract class Customer with _$Customer {
  const factory Customer({
    required CustomerId id,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Customer;
}
