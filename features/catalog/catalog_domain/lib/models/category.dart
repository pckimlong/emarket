import 'package:domain_primitives/domain_primitives.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required CategoryId id,
  }) = _Category;
}
