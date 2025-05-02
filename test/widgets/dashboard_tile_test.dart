import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ai_guardian/widgets/dashboard_tile.dart';

void main() {
  group('DashboardTile widget tests', () {
    Widget createDashboardTile({
      required String image,
      required String label,
      Color? bgColor,
      Color? textColor,
      required VoidCallback onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DashboardTile(
            image: image,
            label: label,
            bgColor: bgColor,
            textColor: textColor,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('renders label and image correctly', (
      WidgetTester tester,
    ) async {
      const image = 'assets/images/logo.png';
      const label = 'Test Label';

      await tester.pumpWidget(
        createDashboardTile(image: image, label: label, onTap: () {}),
      );

      expect(find.text(label), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('applies background and text colors', (
      WidgetTester tester,
    ) async {
      const bgColor = Colors.blue;
      const textColor = Colors.white;

      await tester.pumpWidget(
        createDashboardTile(
          image: 'assets/images/logo.png',
          label: 'Test Label',
          bgColor: bgColor,
          textColor: textColor,
          onTap: () {},
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final text = tester.widget<Text>(find.text('Test Label'));

      expect((container.decoration as BoxDecoration).color, bgColor);
      expect(text.style?.color, textColor);
    });

    testWidgets('triggers onTap callback when tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        createDashboardTile(
          image: 'assets/images/logo.png',
          label: 'Test Label',
          onTap: () {
            tapped = true;
          },
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });
  });
}
