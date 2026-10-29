import 'package:flutter/material.dart';

import 'package:cinema_inventory/helpers.dart';
import 'package:cinema_inventory/app_database.dart';
import 'package:cinema_inventory/inventory_stats.dart';
import 'package:cinema_inventory/action_tile.dart';
import 'package:cinema_inventory/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<InventoryStats> _stats = AppDatabase.instance.getStats();

  void _refresh() {
    setState(() => _stats = AppDatabase.instance.getStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة معدات الإنتاج'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ملخص المخزن',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          FutureBuilder<InventoryStats>(
            future: _stats,
            builder: (context, snap) {
              final s = snap.data;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'إجمالي المعدات',
                          value: '${s?.total ?? 0}',
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'متاحة بالمخزن',
                          value: '${s?.available ?? 0}',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'معدات خارجة',
                          value: '${s?.out ?? 0}',
                          icon: Icons.local_shipping_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'متأخرة',
                          value: '${s?.late ?? 0}',
                          icon: Icons.warning_amber_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'إدارة المعدات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ActionTile(
            icon: Icons.add_box_outlined,
            title: 'إضافة معدة',
            subtitle: 'تسجيل معدة جديدة وسعر إيجارها',
            onTap: () => showMessage(
              context,
              'هنضيف شاشة تسجيل المعدة في الخطوة التالية',
            ),
          ),
          ActionTile(
            icon: Icons.qr_code_scanner,
            title: 'تسجيل خروج أو رجوع',
            subtitle: 'مسح QR لتسجيل حركة المعدة',
            onTap: () =>
                showMessage(context, 'هنضيف مسح QR بعد تجهيز قاعدة البيانات'),
          ),
          ActionTile(
            icon: Icons.list_alt,
            title: 'عرض المعدات',
            subtitle: 'استعراض المعدات وحالتها',
            onTap: () =>
                showMessage(context, 'هنضيف قائمة المعدات في الخطوة التالية'),
          ),
          ActionTile(
            icon: Icons.receipt_long_outlined,
            title: 'الإيجارات والتقارير',
            subtitle: 'متابعة المبالغ وحركات المعدات',
            onTap: () =>
                showMessage(context, 'هنضيف التقارير بعد تسجيل الحركات'),
          ),
        ],
      ),
    );
  }
}
