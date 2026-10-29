class Rental {
  final int? id;
  final int equipmentId;
  final String customer;
  final DateTime outDate;
  final DateTime dueDate;
  final DateTime? returnDate; // null = لسه خارجة
  final double dailyRate; // سعر اليوم وقت الخروج (لو السعر اتغير بعدين)
  final double? total;

  const Rental({
    this.id,
    required this.equipmentId,
    required this.customer,
    required this.outDate,
    required this.dueDate,
    this.returnDate,
    required this.dailyRate,
    this.total,
  });

  bool get isOpen => returnDate == null;
  bool get isLate => isOpen && DateTime.now().isAfter(dueDate);

  Map<String, Object?> toMap() => {
    'id': id,
    'equipment_id': equipmentId,
    'customer': customer,
    'out_date': outDate.toIso8601String(),
    'due_date': dueDate.toIso8601String(),
    'return_date': returnDate?.toIso8601String(),
    'daily_rate': dailyRate,
    'total': total,
  };

  factory Rental.fromMap(Map<String, Object?> m) => Rental(
    id: m['id'] as int,
    equipmentId: m['equipment_id'] as int,
    customer: m['customer'] as String,
    outDate: DateTime.parse(m['out_date'] as String),
    dueDate: DateTime.parse(m['due_date'] as String),
    returnDate: m['return_date'] == null
        ? null
        : DateTime.parse(m['return_date'] as String),
    dailyRate: (m['daily_rate'] as num).toDouble(),
    total: (m['total'] as num?)?.toDouble(),
  );
}
