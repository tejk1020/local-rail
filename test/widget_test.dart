import 'package:flutter_test/flutter_test.dart';

import 'package:college_project/screens/app.dart';

void main() {
  testWidgets(
    'Smart Local Train app loads',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const SmartLocalTrainApp(),
      );

      await tester.pump();

      expect(
        find.text('Smart Local Train'),
        findsOneWidget,
      );
    },
  );
}