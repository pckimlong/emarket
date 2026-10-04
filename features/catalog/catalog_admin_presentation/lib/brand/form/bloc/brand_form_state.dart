import 'package:catalog_domain/catalog_domain.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:presentation_utils/presentation_utils.dart';

part 'brand_form_state.freezed.dart';

@freezed
abstract class BrandFormState with _$BrandFormState {
  const BrandFormState._();

  const factory BrandFormState({
    BrandId? initialBrandId,
    @Default(None()) Option<AsyncState<Brand>> initialFetchStatus,

    @Default('') String name,
    @Default('') String logoPath,
    Uri? logoUri,
    @Default(true) bool isActive,

    /// Reveals validation errors after the first Save attempt.
    @Default(false) bool hasAttemptedSubmit,

    @Default(None()) Option<AsyncState<Brand>> submissionStatus,
  }) = _BrandFormState;

  Either<IList<BrandInputFailure>, BrandInput> get inputResult {
    return BrandInput.create(
      name: name,
      logoPath: logoPath,
      isActive: isActive,
    );
  }

  IList<BrandInputFailure> get failures =>
      inputResult.fold((f) => f, (_) => const IListConst([]));

  bool get isValid => inputResult.isRight();

  BrandInputFailure? failureFor(BrandInputField field) {
    return failures.where((f) => f.field == field).firstOrNull;
  }

  BrandInputFailure? get nameFailure => failureFor(BrandInputField.name);
  BrandInputFailure? get logoFailure => failureFor(BrandInputField.logoPath);

  bool get isEditing => initialBrandId != null;

  bool get isSubmitting => submissionStatus.toNullable()?.isLoading ?? false;

  /// Existing brands must load successfully before their fields can be changed.
  /// Fields remain locked during saving so the result matches the visible input.
  bool get canEdit =>
      !isSubmitting &&
      (!isEditing || initialFetchStatus.toNullable() is AsyncDataState<Brand>);
}
