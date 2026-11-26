import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kisansetu_customer_app/core/storage/storage_service.dart';
import 'package:kisansetu_customer_app/core/widgets/kisan_floating_nav_bar.dart';
import 'package:kisansetu_customer_app/main.dart';

void main() {
  testWidgets('Customer app boots to clean Kisan Setu splash then Phone screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      KisanSetuCustomerApp(
        storageService: LocalStorageServiceImpl(),
        preferencesService: InMemoryPreferencesService(),
      ),
    );

    // Splash shows only Kisan Setu wordmark logo (no pilot corridor, no login buttons)
    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('Pilot'), findsNothing);
    expect(find.text('Get Started'), findsNothing);

    // Let splash sequence transition to Phone Number screen
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Kisan Setu'), findsOneWidget);
    expect(find.text('Enter your mobile number to continue'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
    expect(find.text('Sign in with Password'), findsNothing);
  });

  testWidgets(
      'KisanFloatingNavBar renders only Home, + button, and Categories',
      (WidgetTester tester) async {
    int? selectedTab;
    var addTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: KisanFloatingNavBar(
            selectedIndex: 0,
            onTabSelected: (index) => selectedTab = index,
            onAddPressed: () => addTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.text('Weekly Cart'), findsNothing);
    expect(find.text('Orders'), findsNothing);
    expect(find.text('Profile'), findsNothing);
    expect(find.text('Wallet'), findsNothing);

    await tester.tap(find.text('Categories'));
    expect(selectedTab, 1);

    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(addTapped, isTrue);
  });
}
