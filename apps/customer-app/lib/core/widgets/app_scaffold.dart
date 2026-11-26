import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'kisan_floating_nav_bar.dart';

/// 3-item floating bottom navigation shell: Home | (+) Weekly Cart | Categories.
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
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: KisanFloatingNavBar(
        selectedIndex: selectedIndex,
        onTabSelected: (index) {
          if (index == selectedIndex) return;
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/categories');
              break;
          }
        },
        onAddPressed: () {
          if (currentPath == '/weekly-planner') return;
          context.go('/weekly-planner');
        },
      ),
      floatingActionButton:
          (selectedIndex == 0 || selectedIndex == 1) && cartCount > 0
          ? Transform.translate(
              offset: const Offset(0, 14),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/cart'),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                icon: const Icon(Icons.shopping_basket_outlined),
                label: Text('Cart ($cartCount)'),
              ),
            )
          : null,
    );
  }
}
