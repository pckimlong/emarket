import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Direction of sorting.
enum SortDirection {
  ascending,
  descending;

  bool get isAscending => this == SortDirection.ascending;
  bool get isDescending => this == SortDirection.descending;

  SortDirection get reversed => this == SortDirection.ascending
      ? SortDirection.descending
      : SortDirection.ascending;
}

/// Generic sort rule model specifying which [field] to sort by and in what [direction].
@immutable
final class SortRule<TField> {
  const SortRule({
    required this.field,
    this.direction = SortDirection.ascending,
  });

  final TField field;
  final SortDirection direction;

  SortRule<TField> copyWith({
    TField? field,
    SortDirection? direction,
  }) {
    return SortRule<TField>(
      field: field ?? this.field,
      direction: direction ?? this.direction,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SortRule<TField> &&
        other.field == field &&
        other.direction == direction;
  }

  @override
  int get hashCode => Object.hash(field, direction);

  @override
  String toString() =>
      'SortRule<$TField>(field: $field, direction: $direction)';
}

/// Cycles to the next sort rule for a given [field].
///
/// If [allowUnsorted] is true (default):
/// `null (or different field)` -> `ascending` -> `descending` -> `null (unsorted)`
///
/// If [allowUnsorted] is false:
/// `null (or different field)` -> `ascending` -> `descending` -> `ascending`
SortRule<TField>? nextSortRule<TField>(
  SortRule<TField>? current, {
  required TField field,
  bool allowUnsorted = true,
}) {
  final isActive = current?.field == field;
  final direction = isActive ? current?.direction : null;

  return switch (direction) {
    null => SortRule<TField>(field: field),
    SortDirection.ascending => SortRule<TField>(
      field: field,
      direction: SortDirection.descending,
    ),
    SortDirection.descending =>
      allowUnsorted ? null : SortRule<TField>(field: field),
  };
}

/// Helper comparator function that handles nulls, strings (case-insensitive), and [Comparable] types.
int compareSortValues(
  Comparable? aVal,
  Comparable? bVal, {
  bool nullsLast = true,
  bool caseInsensitive = true,
}) {
  if (aVal == null && bVal == null) return 0;
  if (aVal == null) return nullsLast ? 1 : -1;
  if (bVal == null) return nullsLast ? -1 : 1;

  if (caseInsensitive && aVal is String && bVal is String) {
    return aVal.toLowerCase().compareTo(bVal.toLowerCase());
  }
  return aVal.compareTo(bVal);
}

/// Sorting extensions for [Iterable<T>].
extension SortByRuleIterableX<T> on Iterable<T> {
  /// Sorts items by a [Comparable] value extracted using [selector].
  List<T> sortBySelector(
    Comparable? Function(T item) selector, {
    SortDirection direction = SortDirection.ascending,
    bool nullsLast = true,
    bool caseInsensitive = true,
  }) {
    final list = toList();
    list.sort((a, b) {
      final aVal = selector(a);
      final bVal = selector(b);
      final comparison = compareSortValues(
        aVal,
        bVal,
        nullsLast: nullsLast,
        caseInsensitive: caseInsensitive,
      );
      return direction.isAscending ? comparison : -comparison;
    });
    return list;
  }

  /// Sorts items using a [SortRule] and a mapping of field selectors.
  List<T> sortByRule<TField>(
    SortRule<TField>? rule, {
    required Map<TField, Comparable? Function(T item)> selectors,
    bool nullsLast = true,
    bool caseInsensitive = true,
  }) {
    if (rule == null) return toList();
    final selector = selectors[rule.field];
    if (selector == null) return toList();

    return sortBySelector(
      selector,
      direction: rule.direction,
      nullsLast: nullsLast,
      caseInsensitive: caseInsensitive,
    );
  }
}

/// Sorting extensions for [IList<T>].
extension SortByRuleIListX<T> on IList<T> {
  /// Sorts this immutable list by a [Comparable] value extracted using [selector].
  IList<T> sortBySelector(
    Comparable? Function(T item) selector, {
    SortDirection direction = SortDirection.ascending,
    bool nullsLast = true,
    bool caseInsensitive = true,
  }) {
    return unlock
        .sortBySelector(
          selector,
          direction: direction,
          nullsLast: nullsLast,
          caseInsensitive: caseInsensitive,
        )
        .toIList();
  }

  /// Sorts this immutable list using a [SortRule] and a mapping of field selectors.
  IList<T> sortByRule<TField>(
    SortRule<TField>? rule, {
    required Map<TField, Comparable? Function(T item)> selectors,
    bool nullsLast = true,
    bool caseInsensitive = true,
  }) {
    if (rule == null) return this;
    final selector = selectors[rule.field];
    if (selector == null) return this;

    return sortBySelector(
      selector,
      direction: rule.direction,
      nullsLast: nullsLast,
      caseInsensitive: caseInsensitive,
    );
  }
}
