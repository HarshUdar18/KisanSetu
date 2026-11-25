import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// 5-Tab Primary Bottom Navigation matching Stitch `farmer_dashboard` & `my_produce_management`.
class FarmerScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const FarmerScaffold({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: AppShadows.level2,
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            if (index == selectedIndex) return;
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/produce');
                break;
              case 2:
                context.go('/demand');
                break;
              case 3:
                context.go('/settlements');
                break;
              case 4:
                context.go('/profile');
                break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.agriculture_outlined),
              selectedIcon: Icon(Icons.agriculture),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.eco_outlined),
              selectedIcon: Icon(Icons.eco),
              label: 'My Produce',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Demand',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Settlements',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
