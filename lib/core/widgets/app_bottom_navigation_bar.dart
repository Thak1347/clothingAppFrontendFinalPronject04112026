import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({super.key});

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  bool _isNavigating = false;

  int _selectedIndex(String route) {
    if (route == AppRoutes.cart) return 1;
    if (route == AppRoutes.orders) return 2;
    if (route == AppRoutes.profile) return 3;
    return 0;
  }

  Future<void> _select(int index) async {
    if (_isNavigating) return;
    final route = switch (index) {
      0 => AppRoutes.home,
      1 => AppRoutes.cart,
      2 => AppRoutes.orders,
      _ => AppRoutes.profile,
    };

    if (Get.currentRoute == route) return;
    if (route == AppRoutes.orders &&
        Get.find<AuthController>().user.value == null) {
      setState(() => _isNavigating = true);
      try {
        await Get.toNamed(AppRoutes.login);
      } finally {
        if (mounted) setState(() => _isNavigating = false);
      }
      return;
    }

    setState(() => _isNavigating = true);
    try {
      await Get.offNamed(route);
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex(Get.currentRoute),
      onTap: _isNavigating ? null : _select,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          activeIcon: Icon(Icons.storefront),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
