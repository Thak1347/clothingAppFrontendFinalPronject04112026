import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';

class AdminOverviewPage extends GetView<AdminController> {
  const AdminOverviewPage({
    super.key,
    required this.onOpenOrders,
    required this.onOpenPayments,
    required this.onOpenCatalog,
  });

  final VoidCallback onOpenOrders;
  final VoidCallback onOpenPayments;
  final ValueChanged<int> onOpenCatalog;

  @override
  Widget build(BuildContext context) => Obx(() {
        final data = controller.dashboard;
        final summary = data['summary'] is Map
            ? Map<String, dynamic>.from(data['summary'] as Map)
            : <String, dynamic>{};
        final recent = _mapList(data['recent_orders']);
        final lowStock = _mapList(data['low_stock_variants']);
        final user = Get.find<AuthController>().user.value;
        if (controller.dashboardLoading.value && summary.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (summary.isEmpty && controller.error.value.isNotEmpty) {
          return _retry(
              controller.error.value, () => controller.loadDashboard());
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: RefreshIndicator(
              onRefresh: controller.loadAll,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  const SizedBox(height: 8),
                  Text('Bonjour, ${user?.name ?? 'Admin'}',
                      style: AppTextStyles.displayMdMobile),
                  Text('Flagship & online store',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.inkMuted)),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _period('today', 'Today'),
                      const SizedBox(width: 8),
                      _period('week', 'This week'),
                      const SizedBox(width: 8),
                      _period('month', 'This month'),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  _salesCard(summary),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _metric(
                            'Orders handled',
                            '${_int(summary['orders_count'])}',
                            Icons.shopping_bag_outlined)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _metric(
                            'Awaiting payment',
                            '${_int(summary['pending_payment_count'])}',
                            Icons.hourglass_bottom)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: _metric(
                            'Low stock',
                            '${_int(summary['low_stock_count'])}',
                            Icons.inventory_2_outlined,
                            onTap: () => onOpenCatalog(1))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _metric(
                            'Active products',
                            '${_int(summary['active_products_count'])}',
                            Icons.checkroom_outlined,
                            onTap: () => onOpenCatalog(1))),
                  ]),
                  const SizedBox(height: 22),
                  _section('Action required',
                      '${_int(summary['low_stock_count']) + _int(summary['pending_payment_count'])} items'),
                  const SizedBox(height: 10),
                  if (lowStock.isEmpty &&
                      _int(summary['pending_payment_count']) == 0)
                    _card(const ListTile(
                        leading: Icon(Icons.verified_outlined,
                            color: AppColors.success),
                        title: Text('All caught up'),
                        subtitle:
                            Text('No low-stock variants or pending payments.')))
                  else ...[
                    if (lowStock.isNotEmpty)
                      _card(Column(children: [
                        ListTile(
                            leading: const Icon(Icons.inventory_2_outlined,
                                color: AppColors.warning),
                            title: const Text('Inventory threshold alert'),
                            subtitle: Text(
                                '${lowStock.length} variants have 2 units or fewer'),
                            trailing: TextButton(
                                onPressed: () => onOpenCatalog(1),
                                child: const Text('Review'))),
                        ...lowStock.take(3).map((item) => ListTile(
                            dense: true,
                            title: Text('${item['product_name'] ?? 'Product'}'),
                            subtitle: Text(
                                '${item['size'] ?? ''} · ${item['color'] ?? ''} · SKU ${item['sku'] ?? ''}'),
                            trailing:
                                Text('${item['stock_quantity'] ?? 0} left'))),
                      ])),
                    if (_int(summary['pending_payment_count']) > 0)
                      Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _card(ListTile(
                              leading: const Icon(Icons.payments_outlined,
                                  color: AppColors.warning),
                              title: const Text('Payments need attention'),
                              subtitle: Text(
                                  '${summary['pending_payment_count']} orders are awaiting payment'),
                              trailing: TextButton(
                                  onPressed: onOpenOrders,
                                  child: const Text('View orders'))))),
                  ],
                  const SizedBox(height: 22),
                  _section('Recent orders', 'View all', onTap: onOpenOrders),
                  const SizedBox(height: 10),
                  if (recent.isEmpty)
                    _card(const Padding(
                        padding: EdgeInsets.all(18),
                        child: Text('No orders have been placed yet.')))
                  else
                    ...recent.map((order) => _recentOrder(order, onOpenOrders)),
                  const SizedBox(height: 22),
                  _section('Director controls', 'Quick access'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: _quickAction(Icons.sell_outlined, 'Products',
                            'Manage catalog', () => onOpenCatalog(1))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _quickAction(
                            Icons.category_outlined,
                            'Categories',
                            'Edit collections',
                            () => onOpenCatalog(0))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: _quickAction(Icons.payments_outlined, 'Payments',
                            'Review transactions', onOpenPayments)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _quickAction(Icons.local_shipping_outlined,
                            'Dispatch', 'Fulfill orders', onOpenOrders)),
                  ]),
                  const SizedBox(height: 14),
                  _card(const ListTile(
                      leading: Icon(Icons.verified_user_outlined,
                          color: AppColors.inkMuted),
                      title: Text('Admin access protected'),
                      subtitle: Text(
                          'Store controls are available to admin accounts only.'))),
                ],
              ),
            ),
          ),
        );
      });

  Widget _period(String value, String label) => Obx(() => ChoiceChip(
        label: Text(label),
        selected: controller.dashboardPeriod.value == value,
        onSelected: (_) => controller.loadDashboard(value),
      ));

  Widget _salesCard(Map<String, dynamic> summary) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadowLevel2,
                  blurRadius: 12,
                  offset: Offset(0, 3))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PAID SALES · ${controller.dashboardPeriod.value.toUpperCase()}',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 6),
          Text(
              'USD ${(_int(summary['paid_total_minor']) / 100).toStringAsFixed(2)}',
              style: AppTextStyles.displayMdMobile),
          const SizedBox(height: 8),
          Text('${_int(summary['paid_payment_count'])} verified payments',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted)),
        ]),
      );

  Widget _metric(String title, String value, IconData icon,
          {VoidCallback? onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: _card(Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: AppColors.inkMuted),
              const SizedBox(height: 14),
              Text(value, style: AppTextStyles.headlineLg),
              Text(title,
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted))
            ]))),
      );

  Widget _recentOrder(Map<String, dynamic> order, VoidCallback onTap) =>
      _card(ListTile(
        leading: const CircleAvatar(
            backgroundColor: AppColors.canvas,
            child: Icon(Icons.local_shipping_outlined, color: AppColors.ink)),
        title:
            Text('${order['number'] ?? 'Order'}', style: AppTextStyles.labelMd),
        subtitle: Text(
            '${order['fulfillment_status'] ?? ''} · payment ${_paymentStatus(order)}'),
        trailing: Text(
            '${order['currency'] ?? 'USD'} ${(_int(order['total_minor']) / 100).toStringAsFixed(2)}',
            style: AppTextStyles.priceMd),
        onTap: onTap,
      ));

  Widget _quickAction(
          IconData icon, String title, String subtitle, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: _card(Padding(
            padding: const EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: AppColors.ink),
              const SizedBox(height: 12),
              Text(title, style: AppTextStyles.labelMd),
              Text(subtitle,
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted))
            ]))),
      );

  Widget _section(String title, String action, {VoidCallback? onTap}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headlineSm),
          if (onTap != null)
            TextButton(onPressed: onTap, child: Text(action))
          else
            Text(action,
                style:
                    AppTextStyles.labelSm.copyWith(color: AppColors.inkMuted))
        ],
      );

  Widget _badge(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(icon, size: 14, color: AppColors.inkMuted),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.inkMuted))
        ]),
      );

  Widget _card(Widget child) => Container(
        decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadowLevel2,
                  blurRadius: 10,
                  offset: Offset(0, 2))
            ]),
        child: child,
      );

  Widget _retry(String message, Future<void> Function() action) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: action, child: const Text('Retry')),
        ]),
      );

  List<Map<String, dynamic>> _mapList(dynamic value) =>
      (value as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

  String _paymentStatus(Map<String, dynamic> order) {
    final value = order['payment'];
    if (value is Map && value['data'] is Map) {
      return '${value['data']['status'] ?? 'unknown'}';
    }
    if (value is Map) {
      return '${value['status'] ?? 'unknown'}';
    }
    return 'unknown';
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
