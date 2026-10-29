import 'package:flutter/material.dart';

import 'package:cinema_inventory/add_equipment.dart';
import 'package:cinema_inventory/equipment.dart';
import 'package:cinema_inventory/equipment_categories.dart';
import 'package:cinema_inventory/equipment_repo.dart';
import 'package:cinema_inventory/helpers.dart';

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  late final Stream<List<Equipment>> _stream = EquipmentRepository.instance
      .watchAll();
  String _query = '';

  void _openAdd() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddEquipmentScreen()));
  }

  List<Equipment> _filter(List<Equipment> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (e) =>
              e.name.toLowerCase().contains(q) ||
              e.code.toLowerCase().contains(q) ||
              e.category.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _confirmDelete(Equipment e) async {
    if (e.isOut) {
      showMessage(
        context,
        'This item is checked out. Return it before deleting.',
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete equipment?'),
        content: Text('"${e.name}" (${e.code}) will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await EquipmentRepository.instance.delete(e.code);
      if (!mounted) return;
      showMessage(context, 'Equipment deleted');
    } catch (err) {
      if (!mounted) return;
      showMessage(context, 'Could not delete: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add equipment'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search by name, code or category',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Equipment>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load equipment:\n${snap.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snap.data!;
                if (all.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.inventory_2_outlined,
                    message:
                        'No equipment yet.\nTap "Add equipment" to register your first item.',
                  );
                }

                final items = _filter(all);
                if (items.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.search_off,
                    message: 'No equipment matches your search.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final e = items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(categoryIcon(e.category)),
                        ),
                        title: Text(e.name),
                        subtitle: Text(
                          '${e.category} • ${e.code}\n${formatRate(e.dailyRate)} / day',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StatusChip(equipment: e),
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'delete') _confirmDelete(e);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Equipment equipment;
  const _StatusChip({required this.equipment});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final String label;
    final Color bg;
    final Color fg;
    if (equipment.isLate) {
      label = 'Overdue';
      bg = scheme.errorContainer;
      fg = scheme.onErrorContainer;
    } else if (equipment.isOut) {
      label = 'Checked out';
      bg = scheme.tertiaryContainer;
      fg = scheme.onTertiaryContainer;
    } else {
      label = 'Available';
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: color),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
