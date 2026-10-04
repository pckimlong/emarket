import 'package:catalog_domain/catalog_domain.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdart/fpdart.dart';

abstract class IAdminBrandRepo {
  Stream<IList<Brand>> watchBrands();
  Result<Brand> getBrandById(BrandId brandId);
  Result<Brand> createBrand(BrandInput input);
  Result<Brand> updateBrand(BrandId brandId, BrandInput input);
  Result<Unit> deleteBrand(BrandId brandId);
}
