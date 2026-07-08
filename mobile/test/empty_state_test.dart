import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mambonami/shared/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState renders subtitle text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'Nothing here yet',
            subtitle: 'Add fresh produce to get started.',
          ),
        ),
      ),
    );

    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Add fresh produce to get started.'), findsOneWidget);
  });
}
