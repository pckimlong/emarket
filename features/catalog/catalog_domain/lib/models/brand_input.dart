import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand_input.freezed.dart';

enum BrandInputField {
  name,
  logoPath;

  static const logoUri = logoPath;
}

enum BrandInputFailure {
  nameRequired,
  nameTooShort,
  nameTooLong,
  logoPathRequired,
  logoPathInvalid;

  static const logoUriRequired = logoPathRequired;
  static const logoUriInvalid = logoPathInvalid;

  BrandInputField get field => switch (this) {
    nameRequired || nameTooShort || nameTooLong => BrandInputField.name,
    logoPathRequired || logoPathInvalid => BrandInputField.logoPath,
  };
}

@Freezed(copyWith: false)
abstract class BrandInput with _$BrandInput {
  const BrandInput._();

  const factory BrandInput._internal({
    required String name,
    required String logoPath,
    required bool isActive,
  }) = _BrandInput;

  Uri get logoUri {
    if (logoPath.startsWith('http://') || logoPath.startsWith('https://')) {
      return Uri.tryParse(logoPath) ?? Uri(path: logoPath);
    }
    return Uri(path: logoPath);
  }

  static final _pathRegex = RegExp(r'^[a-zA-Z0-9_\-]+/[a-zA-Z0-9_\.\-]+$');

  static bool _isValidLogoPath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      final parsed = Uri.tryParse(path);
      return parsed != null && parsed.host.isNotEmpty;
    }
    if (path.contains('..')) return false;
    return _pathRegex.hasMatch(path);
  }

  static Either<IList<BrandInputFailure>, BrandInput> create({
    required String name,
    required String logoPath,
    required bool isActive,
  }) {
    final failures = <BrandInputFailure>[];
    final normalizedName = name.trim();
    final normalizedLogo = logoPath.trim();

    if (normalizedName.isEmpty) {
      failures.add(BrandInputFailure.nameRequired);
    } else if (normalizedName.length < 2) {
      failures.add(BrandInputFailure.nameTooShort);
    } else if (normalizedName.length > 100) {
      failures.add(BrandInputFailure.nameTooLong);
    }

    if (normalizedLogo.isEmpty) {
      failures.add(BrandInputFailure.logoPathRequired);
    } else if (!_isValidLogoPath(normalizedLogo)) {
      failures.add(BrandInputFailure.logoPathInvalid);
    }

    if (failures.isNotEmpty) {
      return Left(failures.lock);
    }

    return Right(
      BrandInput._internal(
        name: normalizedName,
        logoPath: normalizedLogo,
        isActive: isActive,
      ),
    );
  }
}
