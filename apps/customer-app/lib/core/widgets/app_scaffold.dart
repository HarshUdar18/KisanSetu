import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../theme/app_theme.dart';

/// 5-tab bottom navigation shell matching Stitch `mobile_tab` design.
class AppScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const AppScaffold({
    super.key,
    required this.child,
    int? selectedIndex,
    int? currentIndex,
  }) : selectedIndex = selectedIndex ?? currentIndex ?? 0;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().cart.itemCount;

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
                context.go('/home');
                break;
              case 1:
                context.go('/categories');
                break;
              case 2:
                context.go('/weekly-planner');
                break;
              case 3:
                context.go('/orders');
                break;
              case 4:
                context.go('/profile');
                break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Weekly Cart',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: (selectedIndex == 0 || selectedIndex == 1) && cartCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/cart'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              icon: const Icon(Icons.shopping_basket_outlined),
              label: Text('Cart ($cartCount)'),
            )
          : null,
    );
  }
}
