import 'package:catalog_domain/catalog_domain.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:presentation_utils/presentation_utils.dart';

part 'brand_list_state.freezed.dart';

@freezed
abstract class BrandListState with _$BrandListState {
  const BrandListState._();

  const factory BrandListState({
    @Default(AsyncState.loading()) AsyncState<IList<Brand>> allBrands,
    @Default(true) bool? activeFilter,
    @Default('') String searchQuery,
  }) = _BrandListState;

  IList<Brand> get brands {
    final all = allBrands.valueOrNull ?? const IListConst([]);

    final statusFiltered = activeFilter == null
        ? all
        : all.where((b) => b.isActive == activeFilter).toIList();

    return statusFiltered.fuzzySearch(
      searchQuery,
      fields: [
        SearchField(name: 'name', getter: (b) => b.name, weight: 1.0),
      ],
    );
  }
}
