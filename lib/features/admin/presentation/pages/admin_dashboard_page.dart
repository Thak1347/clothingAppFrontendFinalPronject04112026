import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/admin_controller.dart';
import 'admin_catalog_page.dart';
import 'admin_orders_page.dart';
import 'admin_overview_page.dart';
import 'admin_payments_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

/// Admin navigation shell. Feature screens live in their own files.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminController controller = Get.find<AdminController>();
  int _selectedTab = 0;
  int _catalogTab = 0;

  void _openCatalog(int tab) {
    setState(() {
      _selectedTab = 2;
      _catalogTab = tab;
    });
  }

  Widget _workspace() => IndexedStack(
        index: _selectedTab,
        children: [
          AdminOverviewPage(
            onOpenOrders: () => setState(() => _selectedTab = 1),
            onOpenPayments: () => setState(() => _selectedTab = 3),
            onOpenCatalog: _openCatalog,
          ),
          const AdminOrdersPage(),
          AdminCatalogPage(
            initialTab: _catalogTab,
            onTabChanged: (index) {
              if (_catalogTab != index) setState(() => _catalogTab = index);
            },
          ),
          const AdminPaymentsPage(),
          const ProfileContent(),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          titleSpacing: 16,
          title: _selectedTab == 4
              ? const Text('Admin profile')
              : Row(children: [
                  const Icon(Icons.checkroom_outlined, size: 25),
                  const SizedBox(width: 8),
                  Text('ÉTOFFE', style: AppTextStyles.headlineSm),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('ADMIN', style: AppTextStyles.labelSm),
                  ),
                ]),
          actions: [
            IconButton(
              tooltip: 'Refresh dashboard',
              onPressed: controller.loadAll,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return _workspace();
          }
          return Row(children: [
            NavigationRail(
              extended: constraints.maxWidth >= 1200,
              minWidth: 76,
              minExtendedWidth: 208,
              backgroundColor: AppColors.surfaceWhite,
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) =>
                  setState(() => _selectedTab = index),
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.space_dashboard_outlined),
                    selectedIcon: Icon(Icons.space_dashboard),
                    label: Text('Overview')),
                NavigationRailDestination(
                    icon: Icon(Icons.local_mall_outlined),
                    selectedIcon: Icon(Icons.local_mall),
                    label: Text('Orders')),
                NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: Text('Catalog')),
                NavigationRailDestination(
                    icon: Icon(Icons.query_stats_outlined),
                    selectedIcon: Icon(Icons.query_stats),
                    label: Text('Payments')),
                NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Profile')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _workspace()),
          ]);
        }),
        bottomNavigationBar: LayoutBuilder(builder: (context, constraints) {
          if (MediaQuery.sizeOf(context).width >= 900) {
            return const SizedBox.shrink();
          }
          return BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (index) => setState(() => _selectedTab = index),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.space_dashboard_outlined),
                  activeIcon: Icon(Icons.space_dashboard),
                  label: 'Overview'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.local_mall_outlined),
                  activeIcon: Icon(Icons.local_mall),
                  label: 'Orders'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2),
                  label: 'Catalog'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.query_stats_outlined),
                  activeIcon: Icon(Icons.query_stats),
                  label: 'Payments'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile'),
            ],
          );
        }),
      );
}
