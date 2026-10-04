import 'package:catalog_data/mappers/brand_mapper.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:data_utils/data_utils.dart';
import 'package:domain_primitives/domain_primitives.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

class AdminBrandRepoImpl({
  required final EndpointAdminBrand _endpoint,
}) extends IAdminBrandRepo with ReactiveListCacheMixin<Brand, BrandId> {
  final _mapper = const BrandMapper();

  @override
  BrandId getItemId(Brand item) => item.id;

  @override
  Future<IList<Brand>> fetchRemoteItems() async {
    final dtoList = await _endpoint.listBrands(isActive: null);
    return _mapper.convertIList<BrandDto, Brand>(dtoList);
  }

  @override
  Stream<IList<Brand>> watchBrands() => watchCachedList();

  @override
  Result<Brand> createBrand(BrandInput input) {
    return failureHandler(() async {
      final dto = BrandDto(
        name: input.name,
        logoPath: input.logoPath,
        isActive: input.isActive,
      );
      final result = await _endpoint.createBrand(dto);
      final newBrand = _mapper.convert<BrandDto, Brand>(result);

      addLocalItem(newBrand);

      return newBrand;
    });
  }

  @override
  Result<Brand> updateBrand(BrandId brandId, BrandInput input) {
    return failureHandler(() async {
      final dto = BrandDto(
        id: brandId.value.toUuidValue(),
        name: input.name,
        logoPath: input.logoPath,
        isActive: input.isActive,
      );
      final result = await _endpoint.updateBrand(dto);
      final updatedBrand = _mapper.convert<BrandDto, Brand>(result);

      updateLocalItem(updatedBrand, brandId);

      return updatedBrand;
    });
  }

  @override
  Result<Unit> deleteBrand(BrandId brandId) {
    return failureHandler(() async {
      await _endpoint.deleteBrand(brandId.value.toUuidValue());

      removeLocalItem(brandId);

      return unit;
    });
  }

  @override
  Result<Brand> getBrandById(BrandId brandId) {
    return failureHandler(() async {
      final result = await _endpoint.getBrandById(brandId.value.toUuidValue());
      return _mapper.convert<BrandDto, Brand>(result);
    });
  }

  @override
  void dispose() => disposeReactiveCache();
}
