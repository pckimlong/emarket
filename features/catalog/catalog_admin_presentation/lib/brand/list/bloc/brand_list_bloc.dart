import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation_utils/presentation_utils.dart';

import 'brand_list_event.dart';
import 'brand_list_state.dart';

final class BrandListBloc extends Bloc<BrandListEvent, BrandListState> {
  final IAdminBrandRepo _brandRepo;

  BrandListBloc({required this._brandRepo, bool? initialActiveFilter = true})
    : super(BrandListState(activeFilter: initialActiveFilter)) {
    on<BrandListWatchEvent>(_onWatch, transformer: restartable());
    on<BrandListSearchChanged>(_onSearchChanged, transformer: debounce());
    on<BrandListFilterChanged>(_onFilterChanged);

    add(const BrandListStarted());
  }

  Future<void> _onWatch(
    BrandListWatchEvent event,
    Emitter<BrandListState> emit,
  ) {
    return emit.onEachAsyncPropertyGuard(
      _brandRepo.watchBrands(),
      current: () => state.allBrands,
      update: (allBrands) => state.copyWith(allBrands: allBrands),
    );
  }

  void _onFilterChanged(
    BrandListFilterChanged event,
    Emitter<BrandListState> emit,
  ) {
    emit(state.copyWith(activeFilter: event.isActive));
  }

  void _onSearchChanged(
    BrandListSearchChanged event,
    Emitter<BrandListState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
