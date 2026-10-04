import 'package:domain_primitives/domain_primitives.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand.freezed.dart';

@freezed
abstract class Brand with _$Brand {
  const factory Brand({
    required BrandId id,
    required String name,
    required Uri logoUri,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Brand;
}
