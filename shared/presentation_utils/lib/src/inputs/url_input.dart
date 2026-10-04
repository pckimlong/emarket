import 'package:formz/formz.dart';

enum UrlValidationError { empty, invalid }

final class UrlInput extends FormzInput<String, UrlValidationError> {
  const UrlInput.pure({
    String value = '',
    this.isRequired = false,
  }) : super.pure(value);

  const UrlInput.dirty({
    String value = '',
    this.isRequired = false,
  }) : super.dirty(value);

  final bool isRequired;

  UrlInput toDirty([String? newValue]) => UrlInput.dirty(
    value: newValue ?? value,
    isRequired: isRequired,
  );

  UrlInput toPure([String? newValue]) => UrlInput.pure(
    value: newValue ?? value,
    isRequired: isRequired,
  );

  Uri? get parsedUri {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return Uri.tryParse(trimmed);
  }

  @override
  UrlValidationError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return isRequired ? UrlValidationError.empty : null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return UrlValidationError.invalid;
    }
    return null;
  }
}
