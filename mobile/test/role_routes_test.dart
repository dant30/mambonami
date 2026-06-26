import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mambonami/config/route_paths.dart';
import 'package:mambonami/config/role_routes.dart';
import 'package:mambonami/shared/widgets/greeting_header.dart';
import 'package:mambonami/shared/widgets/rating_stars.dart';

void main() {
  group('AppRole', () {
    test('returns the expected home route for each supported role', () {
      expect(AppRole.homePathFor(AppRole.buyer), RoutePaths.buyerDashboard);
      expect(AppRole.homePathFor(AppRole.retailer), RoutePaths.buyerDashboard);
      expect(AppRole.homePathFor(AppRole.farmer), RoutePaths.farmerDashboard);
      expect(AppRole.homePathFor(AppRole.transportProvider), RoutePaths.transportProviderDashboard);
      expect(AppRole.homePathFor(AppRole.admin), '/admin');
    });

    test('detects role home paths correctly', () {
      expect(AppRole.isHomePathForRole(RoutePaths.buyerDashboard, AppRole.buyer), isTrue);
      expect(AppRole.isHomePathForRole('/buyer/orders', AppRole.buyer), isTrue);
      expect(AppRole.isHomePathForRole('/farmer', AppRole.buyer), isFalse);
    });
  });

  testWidgets('GreetingHeader shows a time-based emoji', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GreetingHeader(name: 'Ada')));

    final hour = DateTime.now().hour;
    String expectedEmoji;
    if (hour >= 5 && hour < 12) {
      expectedEmoji = '🌅';
    } else if (hour >= 12 && hour < 17) {
      expectedEmoji = '☀️';
    } else if (hour >= 17 && hour < 21) {
      expectedEmoji = '🌆';
    } else {
      expectedEmoji = '🌙';
    }

    expect(find.textContaining(expectedEmoji), findsOneWidget);
  });

  testWidgets('InteractiveRatingStars reports tap selections', (tester) async {
    int? selectedRating;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InteractiveRatingStars(
            initialRating: 2,
            onRatingChanged: (rating) => selectedRating = rating,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pump();

    expect(selectedRating, 3);
  });
}
