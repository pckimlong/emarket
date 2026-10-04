import 'package:emarket_server/src/generated/protocol.dart';
import 'package:emarket_server/src/shared/auth/app_scopes.dart';
import 'package:emarket_server/src/staff/staff_session_extension.dart';
import 'package:serverpod/serverpod.dart';

class AdminBrandEndpoint extends Endpoint {
  AdminBrandEndpoint();

  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {AppScopes.staff};

  Future<List<BrandDto>> listBrands(
    Session session, {
    bool? isActive,
    int? limit,
    int? offset,
  }) async {
    return BrandDto.db.find(
      session,
      where: isActive != null ? (t) => t.isActive.equals(isActive) : null,
      orderBy: (t) => t.name,
      limit: limit,
      offset: offset,
    );
  }

  Future<BrandDto> getBrandById(Session session, UuidValue id) async {
    final brand = await BrandDto.db.findById(session, id);
    if (brand == null) {
      throw NotFoundException(message: 'Brand not found');
    }
    return brand;
  }

  Future<BrandDto> createBrand(Session session, BrandDto brand) async {
    await session.requireAdminStaff();
    return BrandDto.db.insertRow(session, brand);
  }

  Future<BrandDto> updateBrand(Session session, BrandDto brand) async {
    await session.requireAdminStaff();
    final brandId = brand.id;
    if (brandId == null) {
      throw ValidationException(message: 'Brand id is required for update');
    }
    final existing = await BrandDto.db.findById(session, brandId);
    if (existing == null) {
      throw NotFoundException(message: 'Brand not found');
    }
    final updated = await BrandDto.db.updateRow(session, brand);

    if (existing.logoPath != brand.logoPath) {
      await _safeDeleteStorageFile(session, existing.logoPath);
    }

    return updated;
  }

  Future<BrandDto> deleteBrand(Session session, UuidValue id) async {
    await session.requireAdminStaff();

    final brand = await BrandDto.db.findById(session, id);
    if (brand == null) {
      throw NotFoundException(message: 'Brand not found');
    }

    final productCount = await ProductDto.db.count(
      session,
      where: (t) => t.brandId.equals(id),
    );

    if (productCount > 0) {
      throw ConflictException(
        message: 'Cannot delete brand with associated products',
      );
    }

    final deleted = await BrandDto.db.deleteRow(session, brand);
    await _safeDeleteStorageFile(session, deleted.logoPath);
    return deleted;
  }

  Future<void> _safeDeleteStorageFile(Session session, String path) async {
    if (path.isEmpty ||
        path.startsWith('http://') ||
        path.startsWith('https://')) {
      return;
    }
    try {
      await session.storage.deleteFile(
        storageId: 'public',
        path: path,
      );
    } catch (e) {
      session.log(
        'Failed to delete storage file at $path: $e',
        level: LogLevel.warning,
      );
    }
  }
}
