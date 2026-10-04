import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:presentation_utils/presentation_utils.dart';
import 'package:test/test.dart';

class _TestItem {
  final String title;
  final String description;

  const _TestItem({required this.title, required this.description});
}

void main() {
  group('fuzzySearch', () {
    final items = [
      const _TestItem(title: 'Nike Air Max', description: 'Running shoes'),
      const _TestItem(
        title: 'Adidas Ultraboost',
        description: 'Sport athletic sneakers',
      ),
      const _TestItem(
        title: 'Puma Suede',
        description: 'Classic lifestyle shoes',
      ),
    ];

    test('returns original items when query is null or blank', () {
      expect(items.fuzzySearch(null), equals(items));
      expect(items.fuzzySearch('   '), equals(items));
      expect(IList(items).fuzzySearch(null), equals(IList(items)));
    });

    test('searches single field via extract function', () {
      final results = items.fuzzySearch(
        'adidas',
        extract: (item) => item.title,
      );

      expect(results.length, equals(1));
      expect(results.first.title, equals('Adidas Ultraboost'));
    });

    test('handles multi-field search with weights', () {
      final results = items.fuzzySearch(
        'sneakers',
        fields: [
          SearchField(name: 'title', getter: (item) => item.title, weight: 0.8),
          SearchField(
            name: 'description',
            getter: (item) => item.description,
            weight: 0.5,
          ),
        ],
      );

      expect(results.length, equals(1));
      expect(results.first.title, equals('Adidas Ultraboost'));
    });

    test('handles typo tolerance (fuzzy matching)', () {
      final results = items.fuzzySearch(
        'Nkie',
        extract: (item) => item.title,
        threshold: 0.6,
      );

      expect(results.length, equals(1));
      expect(results.first.title, equals('Nike Air Max'));
    });

    test('works on IList<T>', () {
      final ilist = IList(items);
      final results = ilist.fuzzySearch(
        'puma',
        extract: (item) => item.title,
      );

      expect(results, isA<IList<_TestItem>>());
      expect(results.length, equals(1));
      expect(results.first.title, equals('Puma Suede'));
    });
  });
}
