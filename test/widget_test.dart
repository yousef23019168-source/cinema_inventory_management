import 'package:flutter_test/flutter_test.dart';

import 'package:cinema_inventory/equipment.dart';

Equipment _item({bool isOut = false, DateTime? dueDate}) => Equipment(
  code: 'EQ-TEST01',
  name: 'Test camera',
  category: 'Camera',
  dailyRate: 100,
  createdAt: DateTime(2025, 1, 1),
  isOut: isOut,
  dueDate: dueDate,
);

void main() {
  group('Equipment.isLate', () {
    test('is false when the item is in stock', () {
      expect(_item().isLate, isFalse);
    });

    test('is false when out and not yet due', () {
      final e = _item(
        isOut: true,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      );
      expect(e.isLate, isFalse);
    });

    test('is true when out and past the due date', () {
      final e = _item(
        isOut: true,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(e.isLate, isTrue);
    });
  });
}
