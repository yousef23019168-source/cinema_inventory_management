/// One piece of gear. The [code] is the primary key (and what the QR label holds).
class Equipment {
  final String code;
  final String name;
  final String category;
  final double dailyRate;
  final String notes;
  final DateTime createdAt;

  /// Currently rented out?
  final bool isOut;

  /// Expected return date while the item is out.
  final DateTime? dueDate;

  const Equipment({
    required this.code,
    required this.name,
    required this.category,
    required this.dailyRate,
    this.notes = '',
    required this.createdAt,
    this.isOut = false,
    this.dueDate,
  });

  bool get isLate =>
      isOut && dueDate != null && DateTime.now().isAfter(dueDate!);

  String get id => code;

  Map<String, Object?> toMap() => {
    'code': code,
    'name': name,
    'category': category,
    'daily_rate': dailyRate,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'is_out': isOut ? 1 : 0,
    'due_date': dueDate?.toIso8601String(),
  };

  factory Equipment.fromMap(Map<String, Object?> m) => Equipment(
    code: m['code'] as String,
    name: (m['name'] as String?) ?? '',
    category: (m['category'] as String?) ?? 'Other',
    dailyRate: ((m['daily_rate'] as num?) ?? 0).toDouble(),
    notes: (m['notes'] as String?) ?? '',
    createdAt: DateTime.parse(m['created_at'] as String),
    isOut: ((m['is_out'] as int?) ?? 0) == 1,
    dueDate: m['due_date'] == null
        ? null
        : DateTime.parse(m['due_date'] as String),
  );
}
