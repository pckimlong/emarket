import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SampleUser {
  const SampleUser({required this.name, required this.role, required this.age});
  final String name;
  final String role;
  final int age;
}

void main() {
  final testUsers = [
    const SampleUser(name: 'Charlie', role: 'Admin', age: 30),
    const SampleUser(name: 'Alice', role: 'Editor', age: 25),
    const SampleUser(name: 'Bob', role: 'Viewer', age: 35),
  ];

  Widget buildTestWidget({
    required List<SampleUser> items,
    required List<DataColumnDef<SampleUser>> columns,
    ValueChanged<SampleUser>? onRowTap,
    Set<SampleUser>? selectedItems,
    ValueChanged<Set<SampleUser>>? onSelectionChanged,
  }) {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: getAdminLightTheme(),
        child: child!,
      ),
      home: Scaffold(
        body: AdminDataTable<SampleUser>(
          items: items,
          columns: columns,
          onRowTap: onRowTap,
          selectedItems: selectedItems,
          onSelectionChanged: onSelectionChanged,
        ),
      ),
    );
  }

  testWidgets('renders columns and row contents', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      buildTestWidget(
        items: testUsers,
        columns: [
          DataColumnDef(
            header: 'NAME',
            sortValue: (u) => u.name,
            cellBuilder: (context, u) => Text(u.name),
          ),
          DataColumnDef(
            header: 'ROLE',
            cellBuilder: (context, u) => Text(u.role),
          ),
        ],
      ),
    );

    expect(find.text('NAME'), findsOneWidget);
    expect(find.text('ROLE'), findsOneWidget);
    expect(find.text('Charlie'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('clicking sort header sorts ascending then descending', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      buildTestWidget(
        items: testUsers,
        columns: [
          DataColumnDef(
            header: 'NAME',
            sortValue: (u) => u.name,
            cellBuilder: (context, u) => Text(u.name),
          ),
          DataColumnDef(
            header: 'AGE',
            sortValue: (u) => u.age,
            cellBuilder: (context, u) => Text('${u.age}'),
          ),
        ],
      ),
    );

    // Initial order: Charlie, Alice, Bob
    // Click NAME column to sort ascending
    await tester.tap(find.text('NAME'));
    await tester.pumpAndSettle();

    // After ascending sort: Alice, Bob, Charlie
    final namesAfterAsc = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .toList();
    expect(
      namesAfterAsc.indexOf('Alice') < namesAfterAsc.indexOf('Bob'),
      isTrue,
    );
    expect(
      namesAfterAsc.indexOf('Bob') < namesAfterAsc.indexOf('Charlie'),
      isTrue,
    );

    // Click NAME column again to sort descending
    await tester.tap(find.text('NAME'));
    await tester.pumpAndSettle();

    // After descending sort: Charlie, Bob, Alice
    final namesAfterDesc = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .toList();
    expect(
      namesAfterDesc.indexOf('Charlie') < namesAfterDesc.indexOf('Bob'),
      isTrue,
    );
    expect(
      namesAfterDesc.indexOf('Bob') < namesAfterDesc.indexOf('Alice'),
      isTrue,
    );
  });
}
