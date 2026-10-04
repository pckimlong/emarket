import 'package:catalog_data/catalog_data.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:test/test.dart';

void main() {
  final uuid1 = UuidValue.fromString('00000000-0000-0000-0000-000000000001');

  group('Catalog mappers', () {
    test('BrandMapper maps BrandDto to Brand with id', () {
      final dto = BrandDto(
        id: uuid1,
        name: 'Test Brand',
        logoPath: 'https://example.com/logo.png',
        isActive: true,
      );
      const mapper = BrandMapper();
      final domainModel = mapper.convert<BrandDto, Brand>(dto);
      expect(domainModel, isA<Brand>());
      expect(domainModel.id.value, equals(uuid1.uuid));
      expect(domainModel.name, equals('Test Brand'));
      expect(
        domainModel.logoUri,
        equals(Uri.parse('https://example.com/logo.png')),
      );
      expect(domainModel.isActive, isTrue);
    });

    test(
      'BrandMapper resolves relative logoPath to serverpod public storage URL',
      () {
        final dto = BrandDto(
          id: uuid1,
          name: 'Test Brand',
          logoPath: 'brands/logo.webp',
          isActive: true,
        );
        const mapper = BrandMapper();
        final domainModel = mapper.convert<BrandDto, Brand>(dto);
        expect(
          domainModel.logoUri,
          equals(
            Uri.parse(
              'http://localhost:8080/serverpod_cloud_storage?method=file&path=brands%2Flogo.webp',
            ),
          ),
        );
      },
    );

    test('CategoryMapper maps CategoryDto to Category with id', () {
      final dto = CategoryDto(
        id: uuid1,
        shopId: uuid1,
        name: 'Test Category',
        isActive: true,
      );
      const mapper = CategoryMapper();
      final domainModel = mapper.convert<CategoryDto, Category>(dto);
      expect(domainModel, isA<Category>());
      expect(domainModel.id.value, equals(uuid1.uuid));
    });

    test('ProductMapper maps ProductDto to Product with id', () {
      final dto = ProductDto(
        id: uuid1,
        shopId: uuid1,
        name: 'Test Product',
        basePrice: 19.99,
        imagePaths: [],
        isActive: true,
      );
      const mapper = ProductMapper();
      final domainModel = mapper.convert<ProductDto, Product>(dto);
      expect(domainModel, isA<Product>());
      expect(domainModel.id.value, equals(uuid1.uuid));
    });

    test('CatalogMapper maps CatalogDto to Catalog with id', () {
      final dto = CatalogDto(id: uuid1, name: 'Test Catalog', archived: false);
      const mapper = CatalogMapper();
      final domainModel = mapper.convert<CatalogDto, Catalog>(dto);
      expect(domainModel, isA<Catalog>());
      expect(domainModel.id.value, equals(uuid1.uuid));
    });
  });
}
