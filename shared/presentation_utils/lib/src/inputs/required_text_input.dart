import 'package:formz/formz.dart';

enum RequiredTextValidationError { empty, tooShort, tooLong }

final class RequiredTextInput
    extends FormzInput<String, RequiredTextValidationError> {
  const RequiredTextInput.pure({
    String value = '',
    this.minLength = 1,
    this.maxLength,
  }) : super.pure(value);

  const RequiredTextInput.dirty({
    String value = '',
    this.minLength = 1,
    this.maxLength,
  }) : super.dirty(value);

  final int minLength;
  final int? maxLength;

  RequiredTextInput toDirty([String? newValue]) => RequiredTextInput.dirty(
    value: newValue ?? value,
    minLength: minLength,
    maxLength: maxLength,
  );

  RequiredTextInput toPure([String? newValue]) => RequiredTextInput.pure(
    value: newValue ?? value,
    minLength: minLength,
    maxLength: maxLength,
  );

  @override
  RequiredTextValidationError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return RequiredTextValidationError.empty;
    }
    if (trimmed.length < minLength) {
      return RequiredTextValidationError.tooShort;
    }
    if (maxLength != null && trimmed.length > maxLength!) {
      return RequiredTextValidationError.tooLong;
    }
    return null;
  }
}
