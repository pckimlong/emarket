import 'package:formz/formz.dart';

enum EmailValidationError { empty, invalid }

final class EmailInput extends FormzInput<String, EmailValidationError> {
  const EmailInput.pure([super.value = '']) : super.pure();
  const EmailInput.dirty([super.value = '']) : super.dirty();

  EmailInput toDirty([String? newValue]) => EmailInput.dirty(newValue ?? value);
  EmailInput toPure([String? newValue]) => EmailInput.pure(newValue ?? value);

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  @override
  EmailValidationError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return EmailValidationError.empty;
    }
    if (!_emailRegExp.hasMatch(trimmed)) {
      return EmailValidationError.invalid;
    }
    return null;
  }
}
