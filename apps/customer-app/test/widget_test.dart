import 'package:flutter_test/flutter_test.dart';
import 'package:kisansetu_customer_app/main.dart';

void main() {
  testWidgets('Customer app boots to Kisan Setu splash screen successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KisanSetuCustomerApp());
    expect(find.text('Kisan Setu'), findsOneWidget);
    expect(find.text('Fresh From Farms, Directly to You'), findsOneWidget);

    // Let splash timers complete cleanly
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
