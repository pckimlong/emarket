import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fuzzy/fuzzy.dart' as fz;

/// Represents a weighted attribute to search against on type [T].
final class SearchField<T> {
  const SearchField({
    required this.name,
    required this.getter,
    this.weight = 1.0,
  });

  /// Name identifier of the field (e.g. 'name', 'description', 'sku').
  final String name;

  /// Property accessor returning string representation.
  final String? Function(T item) getter;

  /// Relevance weight between 0.0 and 1.0. Higher weights prioritize matches in this field.
  final double weight;

  fz.WeightedKey<T> _toWeightedKey() {
    return fz.WeightedKey<T>(
      name: name,
      getter: (item) => getter(item) ?? '',
      weight: weight,
    );
  }
}

/// Extension providing easy, full-text fuzzy search on [Iterable<T>].
extension FuzzySearchIterableX<T> on Iterable<T> {
  /// Performs full-text fuzzy search over this collection.
  ///
  /// - If [query] is null or blank, returns all items as a [List<T>].
  /// - Specify [fields] to search across multiple properties with custom weights.
  /// - Or provide a single [extract] function (e.g. `(item) => item.name`).
  /// - [threshold]: Match sensitivity between 0.0 (exact match only) and 1.0 (very loose match). Defaults to 0.35.
  List<T> fuzzySearch(
    String? query, {
    List<SearchField<T>>? fields,
    String? Function(T item)? extract,
    double threshold = 0.4,
    bool tokenize = true,
  }) {
    if (query == null || query.trim().isEmpty) {
      return toList();
    }

    final trimmedQuery = query.trim();
    final itemsList = toList();

    if (itemsList.isEmpty) return itemsList;

    final searchKeys = <fz.WeightedKey<T>>[];
    if (fields != null && fields.isNotEmpty) {
      searchKeys.addAll(fields.map((f) => f._toWeightedKey()));
    } else if (extract != null) {
      searchKeys.add(
        fz.WeightedKey<T>(
          name: 'default',
          getter: (item) => extract(item) ?? '',
          weight: 1.0,
        ),
      );
    } else if (T == String) {
      searchKeys.add(
        fz.WeightedKey<T>(
          name: 'self',
          getter: (item) => item as String,
          weight: 1.0,
        ),
      );
    } else {
      searchKeys.add(
        fz.WeightedKey<T>(
          name: 'toString',
          getter: (item) => item.toString(),
          weight: 1.0,
        ),
      );
    }

    final fuse = fz.Fuzzy<T>(
      itemsList,
      options: fz.FuzzyOptions<T>(
        findAllMatches: true,
        tokenize: tokenize,
        threshold: threshold,
        keys: searchKeys,
      ),
    );

    return fuse.search(trimmedQuery).map((r) => r.item).toList();
  }
}

/// Extension providing easy, full-text fuzzy search on [IList<T>].
extension FuzzySearchIListX<T> on IList<T> {
  /// Performs full-text fuzzy search over this immutable list, returning a new [IList<T>].
  ///
  /// - If [query] is null or blank, returns this list unchanged.
  /// - Specify [fields] to search across multiple properties with custom weights.
  /// - Or provide a single [extract] function (e.g. `(item) => item.name`).
  /// - [threshold]: Match sensitivity between 0.0 (exact match only) and 1.0 (very loose match). Defaults to 0.4.
  IList<T> fuzzySearch(
    String? query, {
    List<SearchField<T>>? fields,
    String? Function(T item)? extract,
    double threshold = 0.4,
    bool tokenize = true,
  }) {
    if (query == null || query.trim().isEmpty) return this;
    return unlock
        .fuzzySearch(
          query,
          fields: fields,
          extract: extract,
          threshold: threshold,
          tokenize: tokenize,
        )
        .toIList();
  }
}
