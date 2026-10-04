import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:presentation_utils/presentation_utils.dart';
import 'package:test/test.dart';

enum TestSortField { name, age, score }

class TestItem {
  const TestItem({
    required this.name,
    required this.age,
    this.score,
  });

  final String name;
  final int age;
  final double? score;

  @override
  String toString() => 'TestItem(name: $name, age: $age, score: $score)';
}

void main() {
  group('SortDirection', () {
    test('isAscending and isDescending properties', () {
      expect(SortDirection.ascending.isAscending, isTrue);
      expect(SortDirection.ascending.isDescending, isFalse);
      expect(SortDirection.descending.isAscending, isFalse);
      expect(SortDirection.descending.isDescending, isTrue);
    });

    test('reversed returns opposite direction', () {
      expect(
        SortDirection.ascending.reversed,
        equals(SortDirection.descending),
      );
      expect(
        SortDirection.descending.reversed,
        equals(SortDirection.ascending),
      );
    });
  });

  group('SortRule', () {
    test('equality and hashCode', () {
      const rule1 = SortRule(field: TestSortField.name);
      const rule2 = SortRule(field: TestSortField.name);
      const rule3 = SortRule(
        field: TestSortField.name,
        direction: SortDirection.descending,
      );
      const rule4 = SortRule(field: TestSortField.age);

      expect(rule1, equals(rule2));
      expect(rule1.hashCode, equals(rule2.hashCode));
      expect(rule1, isNot(equals(rule3)));
      expect(rule1, isNot(equals(rule4)));
    });

    test('copyWith works correctly', () {
      const rule = SortRule(field: TestSortField.name);
      final updated = rule.copyWith(direction: SortDirection.descending);
      expect(updated.field, equals(TestSortField.name));
      expect(updated.direction, equals(SortDirection.descending));
    });
  });

  group('nextSortRule', () {
    test('cycles correctly with allowUnsorted = true', () {
      // null -> ascending
      final first = nextSortRule<TestSortField>(
        null,
        field: TestSortField.name,
      );
      expect(
        first,
        equals(
          const SortRule(
            field: TestSortField.name,
            direction: SortDirection.ascending,
          ),
        ),
      );

      // ascending -> descending
      final second = nextSortRule<TestSortField>(
        first,
        field: TestSortField.name,
      );
      expect(
        second,
        equals(
          const SortRule(
            field: TestSortField.name,
            direction: SortDirection.descending,
          ),
        ),
      );

      // descending -> null
      final third = nextSortRule<TestSortField>(
        second,
        field: TestSortField.name,
      );
      expect(third, isNull);

      // switching field resets to ascending
      final diffField = nextSortRule<TestSortField>(
        second,
        field: TestSortField.age,
      );
      expect(
        diffField,
        equals(
          const SortRule(
            field: TestSortField.age,
            direction: SortDirection.ascending,
          ),
        ),
      );
    });

    test('cycles correctly with allowUnsorted = false', () {
      const currentDesc = SortRule(
        field: TestSortField.name,
        direction: SortDirection.descending,
      );
      final next = nextSortRule<TestSortField>(
        currentDesc,
        field: TestSortField.name,
        allowUnsorted: false,
      );
      expect(
        next,
        equals(
          const SortRule(
            field: TestSortField.name,
            direction: SortDirection.ascending,
          ),
        ),
      );
    });
  });

  group('Sorting Extensions', () {
    final items = [
      const TestItem(name: 'Charlie', age: 30, score: 85.5),
      const TestItem(name: 'alice', age: 25, score: null),
      const TestItem(name: 'Bob', age: 35, score: 92.0),
    ];

    test('sortBySelector - case insensitive string ascending', () {
      final sorted = items.sortBySelector((i) => i.name);
      expect(
        sorted.map((i) => i.name).toList(),
        equals(['alice', 'Bob', 'Charlie']),
      );
    });

    test('sortBySelector - descending', () {
      final sorted = items.sortBySelector(
        (i) => i.age,
        direction: SortDirection.descending,
      );
      expect(sorted.map((i) => i.age).toList(), equals([35, 30, 25]));
    });

    test('sortBySelector - handles nulls with nullsLast', () {
      final sortedAsc = items.sortBySelector((i) => i.score, nullsLast: true);
      expect(
        sortedAsc.map((i) => i.name).toList(),
        equals(['Charlie', 'Bob', 'alice']),
      );

      final sortedNullsFirst = items.sortBySelector(
        (i) => i.score,
        nullsLast: false,
      );
      expect(
        sortedNullsFirst.map((i) => i.name).toList(),
        equals(['alice', 'Charlie', 'Bob']),
      );
    });

    test('sortByRule on Iterable', () {
      final selectors = <TestSortField, Comparable? Function(TestItem)>{
        TestSortField.name: (i) => i.name,
        TestSortField.age: (i) => i.age,
        TestSortField.score: (i) => i.score,
      };

      const rule = SortRule(
        field: TestSortField.age,
        direction: SortDirection.ascending,
      );
      final sorted = items.sortByRule(rule, selectors: selectors);
      expect(sorted.map((i) => i.age).toList(), equals([25, 30, 35]));

      // null rule returns original list
      final unsorted = items.sortByRule(null, selectors: selectors);
      expect(unsorted, equals(items));
    });

    test('sortByRule on IList', () {
      final iList = items.toIList();
      final selectors = <TestSortField, Comparable? Function(TestItem)>{
        TestSortField.name: (i) => i.name,
        TestSortField.age: (i) => i.age,
      };

      const rule = SortRule(
        field: TestSortField.name,
        direction: SortDirection.ascending,
      );
      final sorted = iList.sortByRule(rule, selectors: selectors);
      expect(
        sorted.map((i) => i.name).toList(),
        equals(['alice', 'Bob', 'Charlie']),
      );
    });
  });
}
