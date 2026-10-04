import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:presentation_utils/presentation_utils.dart';

import 'brand_form_event.dart';
import 'brand_form_state.dart';

class BrandFormBloc extends Bloc<BrandFormEvent, BrandFormState> {
  final IAdminBrandRepo _brandRepo;
  final BrandId? _brandId;

  BrandFormBloc({required this._brandRepo, this._brandId})
    : super(BrandFormState(initialBrandId: _brandId)) {
    on<BrandFormStarted>(_onStarted, transformer: restartable());
    on<BrandFormSubmitted>(_onSubmitted, transformer: droppable());
    on<BrandFormIsActiveChanged>(
      (event, emit) {
        if (!state.canEdit) return;
        emit(state.copyWith(isActive: event.isActive));
      },
    );
    on<BrandFormNameChanged>(
      (event, emit) {
        if (!state.canEdit) return;
        emit(state.copyWith(name: event.name));
      },
    );
    on<BrandFormLogoChanged>(
      (event, emit) {
        if (!state.canEdit) return;
        emit(
          state.copyWith(
            logoPath: event.logoPath ?? '',
            logoUri: event.previewUri,
          ),
        );
      },
    );
    on<BrandFormLogoUriChanged>(
      (event, emit) {
        if (!state.canEdit) return;
        emit(
          state.copyWith(
            logoPath: event.logoUri,
            logoUri: Uri.tryParse(event.logoUri),
          ),
        );
      },
    );

    add(const BrandFormStarted());
  }

  Future<void> _onStarted(
    BrandFormStarted event,
    Emitter<BrandFormState> emit,
  ) async {
    if (_brandId == null || state.isSubmitting) return;

    emit(state.copyWith(initialFetchStatus: const Some(.loading())));

    final result = await _brandRepo.getBrandById(_brandId).run();
    if (emit.isDone) return;

    result.fold(
      (failure) => emit(
        state.copyWith(initialFetchStatus: Some(.error(failure))),
      ),
      (brand) {
        final logoPath =
            brand.logoUri.queryParameters['path'] ?? brand.logoUri.toString();
        emit(
          state.copyWith(
            name: brand.name,
            logoPath: logoPath,
            logoUri: brand.logoUri,
            isActive: brand.isActive,
            initialFetchStatus: Some(.data(brand)),
          ),
        );
      },
    );
  }

  Future<void> _onSubmitted(
    BrandFormSubmitted event,
    Emitter<BrandFormState> emit,
  ) async {
    if (!state.canEdit) return;

    final input = state.inputResult.toNullable();

    // An invalid attempt also clears the previous save result.
    emit(
      state.copyWith(
        hasAttemptedSubmit: true,
        submissionStatus: input == null
            ? const None()
            : const Some(AsyncState<Brand>.loading()),
      ),
    );

    if (input == null) return;

    final operation = _brandId == null
        ? _brandRepo.createBrand(input)
        : _brandRepo.updateBrand(_brandId, input);

    final result = await operation.run();
    if (emit.isDone) return;

    final status = result.fold(
      (failure) => AsyncState<Brand>.error(failure),
      (brand) => AsyncState<Brand>.data(brand),
    );

    emit(state.copyWith(submissionStatus: Some(status)));
  }
}
