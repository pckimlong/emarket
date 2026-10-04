import 'package:catalog_domain/catalog_domain.dart';
import 'package:test/test.dart';

void main() {
  group('BrandInput', () {
    test('creates valid BrandInput with relative path and trims strings', () {
      final result = BrandInput.create(
        name: '  Nike  ',
        logoPath: '  brands/550e8400-e29b-41d4-a716-446655440000.webp  ',
        isActive: true,
      );

      expect(result.isRight(), isTrue);
      final input = result.toNullable()!;
      expect(input.name, 'Nike');
      expect(
        input.logoPath,
        'brands/550e8400-e29b-41d4-a716-446655440000.webp',
      );
      expect(input.isActive, isTrue);
      expect(
        input.logoUri,
        Uri(path: 'brands/550e8400-e29b-41d4-a716-446655440000.webp'),
      );
    });

    test('creates valid BrandInput with full URL', () {
      final result = BrandInput.create(
        name: 'Adidas',
        logoPath: 'https://example.com/adidas.png',
        isActive: true,
      );

      expect(result.isRight(), isTrue);
      final input = result.toNullable()!;
      expect(input.name, 'Adidas');
      expect(input.logoPath, 'https://example.com/adidas.png');
      expect(input.logoUri, Uri.parse('https://example.com/adidas.png'));
    });

    test('accumulates failures when both name and logoPath are invalid', () {
      final result = BrandInput.create(
        name: '',
        logoPath: '',
        isActive: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failures) {
          expect(failures.length, 2);
          expect(failures, contains(BrandInputFailure.nameRequired));
          expect(failures, contains(BrandInputFailure.logoPathRequired));
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('rejects path with directory traversal', () {
      final result = BrandInput.create(
        name: 'Nike',
        logoPath: 'brands/../etc/passwd',
        isActive: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failures) =>
            expect(failures, contains(BrandInputFailure.logoPathInvalid)),
        (_) => fail('Expected Left'),
      );
    });

    test('rejects path without a folder namespace', () {
      final result = BrandInput.create(
        name: 'Nike',
        logoPath: 'justlogo.png',
        isActive: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failures) =>
            expect(failures, contains(BrandInputFailure.logoPathInvalid)),
        (_) => fail('Expected Left'),
      );
    });
  });
}
