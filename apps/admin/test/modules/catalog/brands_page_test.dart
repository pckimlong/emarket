import 'package:admin/modules/catalog/brands_page.dart';
import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:catalog_admin_presentation/catalog_admin_presentation.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('BrandsPage', () {
    testWidgets('renders BrandListModule with provided IAdminBrandRepo', (
      tester,
    ) async {
      final fakeRepo = FakeBrandRepo();
      final brand = Brand(
        id: const BrandId('b-1'),
        name: 'Apple',
        logoUri: Uri.parse('https://example.com/apple.png'),
        isActive: true,
      );
      fakeRepo.emitBrands(IList([brand]));

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => FTheme(
            data: getAdminLightTheme(),
            child: child!,
          ),
          home: Scaffold(
            body: RepositoryProvider<IAdminBrandRepo>.value(
              value: fakeRepo,
              child: const BrandsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BrandsPage), findsOneWidget);
      expect(find.byType(BrandListModule), findsOneWidget);
    });
  });
}
