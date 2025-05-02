import 'package:flutter_test/flutter_test.dart';
import 'package:ai_guardian/widgets/dashboard.dart';
import 'package:ai_guardian/widgets/dashboard_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MockUser implements User {
  @override
  String? get displayName => 'Test User';

  @override
  String? get photoURL => 'http://example.com/photo.png';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Dashboard widget tests', () {
    Widget createDashboard(User? user, List<DashboardTile> tiles) {
      return MaterialApp(
        home: Scaffold(body: Dashboard(user: user, tiles: tiles)),
      );
    }

    testWidgets('displays user information when user is provided', (
      WidgetTester tester,
    ) async {
      final user = MockUser();
      final tiles = <DashboardTile>[];

      await tester.pumpWidget(createDashboard(user, tiles));

      expect(find.text('Welcome, Test User'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays default user information when user is null', (
      WidgetTester tester,
    ) async {
      final tiles = <DashboardTile>[];

      await tester.pumpWidget(createDashboard(null, tiles));

      expect(find.text('Welcome, User'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders all dashboard tiles', (WidgetTester tester) async {
      final tiles = List.generate(
        4,
        (index) => DashboardTile(label: 'Tile $index', image: 'assets/images/logo.png', onTap: () {}),
      );

      await tester.pumpWidget(createDashboard(null, tiles));

      for (var i = 0; i < tiles.length; i++) {
        expect(find.text('Tile $i'), findsOneWidget);
      }
    });

    testWidgets('handles empty tiles list gracefully', (
      WidgetTester tester,
    ) async {
      final tiles = <DashboardTile>[];

      await tester.pumpWidget(createDashboard(null, tiles));

      expect(find.byType(DashboardTile), findsNothing);
    });
  });
}
