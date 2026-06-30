import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mambonami/main.dart';
import 'package:mambonami/config/routes.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();

    final hiveTestPath = Directory('${Directory.current.path}/test/hive_test');
    await hiveTestPath.create(recursive: true);
    Hive.init(hiveTestPath.path);

    await setupDependencies(false, AppRouter());
  });

  testWidgets('app boots with MaterialApp.router', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(appRouter: AppRouter()));

    expect(find.byType(MyApp), findsOneWidget);
  });
}
