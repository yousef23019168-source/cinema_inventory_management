import 'package:flutter/material.dart';

import 'package:cinema_inventory/action_tile.dart';
import 'package:cinema_inventory/add_equipment.dart';
import 'package:cinema_inventory/apptheme.dart';
import 'package:cinema_inventory/availability_hero.dart';
import 'package:cinema_inventory/equipment_list.dart';
import 'package:cinema_inventory/equipment_repo.dart';
import 'package:cinema_inventory/helpers.dart';
import 'package:cinema_inventory/inventory_stats.dart';
import 'package:cinema_inventory/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<InventoryStats> _stats = EquipmentRepository.instance
      .watchStats();

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _comingSoon() => showMessage(context, 'Coming soon');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: _comingSoon,
        child: const Icon(Icons.qr_code_scanner, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const _NavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              active: true,
            ),
            _NavItem(
              icon: Icons.inventory_2_outlined,
              label: 'Equipment',
              onTap: () => _push(const EquipmentListScreen()),
            ),
            const SizedBox(width: 56), // space for the FAB
            _NavItem(
              icon: Icons.receipt_long_outlined,
              label: 'Rentals',
              onTap: _comingSoon,
            ),
            _NavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Reports',
              onTap: _comingSoon,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const _Header(),
            const SizedBox(height: 16),
            StreamBuilder<InventoryStats>(
              stream: _stats,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Text('Could not load summary: ${snap.error}');
                }
                final s = snap.data;
                return Column(
                  children: [
                    AvailabilityHero(
                      total: s?.total ?? 0,
                      available: s?.available ?? 0,
                      out: s?.out ?? 0,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'Available',
                            value: '${s?.available ?? 0}',
                            icon: Icons.check_circle_outline,
                            color: AppTheme.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SummaryCard(
                            title: 'Checked out',
                            value: '${s?.out ?? 0}',
                            icon: Icons.local_shipping_outlined,
                            color: AppTheme.info,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SummaryCard(
                            title: 'Overdue',
                            value: '${s?.late ?? 0}',
                            icon: Icons.warning_amber_rounded,
                            color: AppTheme.danger,
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
              'Manage Equipment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ActionTile(
              icon: Icons.add_box_outlined,
              title: 'Add equipment',
              subtitle: 'Register new gear and its daily rate',
              color: AppTheme.accent,
              onTap: () => _push(const AddEquipmentScreen()),
            ),
            ActionTile(
              icon: Icons.list_alt,
              title: 'View equipment',
              subtitle: 'Browse all gear and its status',
              color: AppTheme.success,
              onTap: () => _push(const EquipmentListScreen()),
            ),
            ActionTile(
              icon: Icons.qr_code_scanner,
              title: 'Check out / return',
              subtitle: 'Scan a QR code to log a movement',
              color: AppTheme.info,
              onTap: _comingSoon,
            ),
            ActionTile(
              icon: Icons.receipt_long_outlined,
              title: 'Rentals & reports',
              subtitle: 'Track amounts and gear movements',
              color: AppTheme.purple,
              onTap: _comingSoon,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.movie_creation_outlined,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory system',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            const Text(
              'Equipment Manager',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppTheme.accent
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
