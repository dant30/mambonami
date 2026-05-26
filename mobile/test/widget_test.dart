import 'package:flutter_test/flutter_test.dart';

import 'package:mambonami/main.dart';

void main() {
  testWidgets('app boots with MaterialApp.router', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byType(MyApp), findsOneWidget);
  });
}
