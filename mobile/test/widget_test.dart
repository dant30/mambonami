import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mambonami/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await setupDependencies(false);
  });

  testWidgets('app boots with MaterialApp.router', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byType(MyApp), findsOneWidget);
  });
}
