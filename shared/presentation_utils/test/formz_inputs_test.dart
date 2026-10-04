import 'package:presentation_utils/presentation_utils.dart';
import 'package:test/test.dart';

void main() {
  group('RequiredTextInput', () {
    test('pure input is pure and valid/invalid according to value', () {
      const input = RequiredTextInput.pure();
      expect(input.isPure, isTrue);
      expect(input.value, isEmpty);
      expect(input.displayError, isNull);
      expect(input.error, RequiredTextValidationError.empty);
    });

    test(
      'dirty empty input returns empty error and displayError is non-null',
      () {
        const input = RequiredTextInput.dirty();
        expect(input.isPure, isFalse);
        expect(input.displayError, RequiredTextValidationError.empty);
      },
    );

    test('validates minimum length', () {
      const input = RequiredTextInput.dirty(value: 'a', minLength: 2);
      expect(input.error, RequiredTextValidationError.tooShort);

      const validInput = RequiredTextInput.dirty(value: 'ab', minLength: 2);
      expect(validInput.isValid, isTrue);
      expect(validInput.error, isNull);
    });

    test('validates maximum length', () {
      const input = RequiredTextInput.dirty(
        value: 'abc',
        minLength: 1,
        maxLength: 2,
      );
      expect(input.error, RequiredTextValidationError.tooLong);
    });

    test('toDirty preserves minLength and maxLength while changing value and purity', () {
      const input = RequiredTextInput.pure(
        value: 'a',
        minLength: 2,
        maxLength: 5,
      );
      final dirty = input.toDirty('abcd');

      expect(dirty.isPure, isFalse);
      expect(dirty.value, 'abcd');
      expect(dirty.minLength, 2);
      expect(dirty.maxLength, 5);
      expect(dirty.isValid, isTrue);

      final dirtySameValue = input.toDirty();
      expect(dirtySameValue.isPure, isFalse);
      expect(dirtySameValue.value, 'a');
      expect(dirtySameValue.minLength, 2);
    });

    test('toPure converts dirty input to pure', () {
      const dirty = RequiredTextInput.dirty(value: 'ab', minLength: 2);
      final pure = dirty.toPure();
      expect(pure.isPure, isTrue);
      expect(pure.value, 'ab');
      expect(pure.minLength, 2);
    });
  });

  group('EmailInput', () {
    test('pure input is pure and has empty error', () {
      const input = EmailInput.pure();
      expect(input.isPure, isTrue);
      expect(input.displayError, isNull);
      expect(input.error, EmailValidationError.empty);
    });

    test('invalid email format returns invalid error', () {
      const input = EmailInput.dirty('invalid-email');
      expect(input.isValid, isFalse);
      expect(input.displayError, EmailValidationError.invalid);
    });

    test('valid email passes validation', () {
      const input = EmailInput.dirty('test@emarket.local');
      expect(input.isValid, isTrue);
      expect(input.error, isNull);
      expect(input.displayError, isNull);
    });

    test('toDirty and toPure transform EmailInput purity', () {
      const pure = EmailInput.pure();
      final dirty = pure.toDirty('test@emarket.local');
      expect(dirty.isPure, isFalse);
      expect(dirty.value, 'test@emarket.local');

      final backToPure = dirty.toPure();
      expect(backToPure.isPure, isTrue);
      expect(backToPure.value, 'test@emarket.local');
    });
  });

  group('UrlInput', () {
    test('optional pure URL is valid when empty', () {
      const input = UrlInput.pure();
      expect(input.isPure, isTrue);
      expect(input.isValid, isTrue);
      expect(input.error, isNull);
      expect(input.parsedUri, isNull);
    });

    test('required pure URL requires value', () {
      const input = UrlInput.pure(isRequired: true);
      expect(input.isValid, isFalse);
      expect(input.error, UrlValidationError.empty);
    });

    test('valid http and https URLs pass validation and parse Uri', () {
      const input = UrlInput.dirty(value: 'https://example.com/logo.png');
      expect(input.isValid, isTrue);
      expect(input.parsedUri, Uri.parse('https://example.com/logo.png'));
    });

    test('invalid URL returns invalid error', () {
      const input = UrlInput.dirty(value: 'not-a-url');
      expect(input.isValid, isFalse);
      expect(input.displayError, UrlValidationError.invalid);
    });

    test('toDirty preserves isRequired configuration', () {
      const input = UrlInput.pure(isRequired: true);
      final dirty = input.toDirty('https://example.com');
      expect(dirty.isPure, isFalse);
      expect(dirty.isRequired, isTrue);
      expect(dirty.isValid, isTrue);

      final dirtySameValue = input.toDirty();
      expect(dirtySameValue.isPure, isFalse);
      expect(dirtySameValue.isRequired, isTrue);
      expect(dirtySameValue.isValid, isFalse);
    });

    test('toPure converts dirty UrlInput to pure', () {
      const dirty = UrlInput.dirty(
        value: 'https://example.com',
        isRequired: true,
      );
      final pure = dirty.toPure();
      expect(pure.isPure, isTrue);
      expect(pure.isRequired, isTrue);
      expect(pure.value, 'https://example.com');
    });
  });
}
