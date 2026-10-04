import 'package:domain_primitives/domain_primitives.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{feature_name}}.freezed.dart';

@freezed
abstract class {{class_name}} with _${{class_name}} {
  const factory {{class_name}}({
    required {{class_name}}Id id,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _{{class_name}};
}
