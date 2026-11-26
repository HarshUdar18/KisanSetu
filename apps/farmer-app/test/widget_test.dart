import 'package:flutter_test/flutter_test.dart';
import 'package:kisansetu_farmer_app/main.dart';

void main() {
  testWidgets('Farmer app boots to Kisan Setu Farmer splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KisanSetuFarmerApp());
    expect(find.text('Kisan Setu Farmer'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
