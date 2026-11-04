import 'package:flutter/material.dart';

import 'admin_categories_page.dart';
import 'admin_products_page.dart';

/// Category and product management workspace.
class AdminCatalogPage extends StatefulWidget {
  const AdminCatalogPage({super.key, required this.initialTab, this.onTabChanged});

  final int initialTab;
  final ValueChanged<int>? onTabChanged;

  @override
  State<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends State<AdminCatalogPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);

  }

  @override
  void didUpdateWidget(covariant AdminCatalogPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) _tabs.animateTo(widget.initialTab);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        TabBar(
          controller: _tabs,
          onTap: (index) => widget.onTabChanged?.call(index),
          tabs: const [Tab(text: 'Categories'), Tab(text: 'Products & stock')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [AdminCategoriesPage(), AdminProductsPage()],
          ),
        ),
      ]);
}

