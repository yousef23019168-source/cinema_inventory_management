class InventoryStats {
  final int total;
  final int available;
  final int out;
  final int late;

  const InventoryStats({
    required this.total,
    required this.available,
    required this.out,
    required this.late,
  });
}
