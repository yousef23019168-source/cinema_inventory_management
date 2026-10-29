class Equipment {
  final int? id;
  final String name;
  final String code; // الكود اللي هيتحط في QR
  final String category;
  final double dailyRate;
  final String notes;
  final DateTime createdAt;

  /// بتتحسب من قاعدة البيانات (فيه إيجار مفتوح ولا لأ)
  final bool isOut;

  const Equipment({
    this.id,
    required this.name,
    required this.code,
    this.category = '',
    required this.dailyRate,
    this.notes = '',
    required this.createdAt,
    this.isOut = false,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'code': code,
    'category': category,
    'daily_rate': dailyRate,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  factory Equipment.fromMap(Map<String, Object?> m) => Equipment(
    id: m['id'] as int,
    name: m['name'] as String,
    code: m['code'] as String,
    category: (m['category'] as String?) ?? '',
    dailyRate: (m['daily_rate'] as num).toDouble(),
    notes: (m['notes'] as String?) ?? '',
    createdAt: DateTime.parse(m['created_at'] as String),
    isOut: ((m['is_out'] as int?) ?? 0) == 1,
  );
}
