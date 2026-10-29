import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:cinema_inventory/equipment.dart';
import 'package:cinema_inventory/inventory_stats.dart';
import 'package:cinema_inventory/rental.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'cinema_inventory.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE equipment (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            code TEXT NOT NULL UNIQUE,
            category TEXT NOT NULL DEFAULT '',
            daily_rate REAL NOT NULL,
            notes TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE rentals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            equipment_id INTEGER NOT NULL REFERENCES equipment(id),
            customer TEXT NOT NULL,
            out_date TEXT NOT NULL,
            due_date TEXT NOT NULL,
            return_date TEXT,
            daily_rate REAL NOT NULL,
            total REAL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_rentals_equipment ON rentals(equipment_id)',
        );
        await db.execute(
          'CREATE INDEX idx_rentals_open ON rentals(return_date)',
        );
      },
    );
  }

  // ---------------- المعدات ----------------

  Future<int> insertEquipment(Equipment e) async {
    final d = await db;
    return d.insert('equipment', e.toMap()..remove('id'));
  }

  Future<void> updateEquipment(Equipment e) async {
    final d = await db;
    await d.update('equipment', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  /// مع حساب حالة "خارجة" من الإيجارات المفتوحة
  static const _selectWithStatus = '''
    SELECT e.*,
      EXISTS(
        SELECT 1 FROM rentals r
        WHERE r.equipment_id = e.id AND r.return_date IS NULL
      ) AS is_out
    FROM equipment e
  ''';

  Future<List<Equipment>> getAllEquipment() async {
    final d = await db;
    final rows = await d.rawQuery('$_selectWithStatus ORDER BY e.name');
    return rows.map(Equipment.fromMap).toList();
  }

  Future<Equipment?> getEquipmentByCode(String code) async {
    final d = await db;
    final rows = await d.rawQuery('$_selectWithStatus WHERE e.code = ?', [
      code,
    ]);
    return rows.isEmpty ? null : Equipment.fromMap(rows.first);
  }

  Future<bool> codeExists(String code) async {
    final d = await db;
    final rows = await d.query(
      'equipment',
      columns: ['id'],
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  // ---------------- الخروج والرجوع ----------------

  /// تسجيل خروج معدة. بيرمي Exception لو المعدة خارجة بالفعل.
  Future<int> checkOut({
    required int equipmentId,
    required String customer,
    required DateTime dueDate,
  }) async {
    final d = await db;
    return d.transaction((txn) async {
      final open = await txn.query(
        'rentals',
        where: 'equipment_id = ? AND return_date IS NULL',
        whereArgs: [equipmentId],
        limit: 1,
      );
      if (open.isNotEmpty) {
        throw StateError('المعدة دي خارجة بالفعل');
      }
      final eq = await txn.query(
        'equipment',
        where: 'id = ?',
        whereArgs: [equipmentId],
        limit: 1,
      );
      if (eq.isEmpty) throw StateError('المعدة غير موجودة');

      return txn.insert('rentals', {
        'equipment_id': equipmentId,
        'customer': customer,
        'out_date': DateTime.now().toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'return_date': null,
        'daily_rate': (eq.first['daily_rate'] as num).toDouble(),
        'total': null,
      });
    });
  }

  /// تسجيل رجوع معدة وحساب الإجمالي (أي جزء من اليوم = يوم كامل، والحد الأدنى يوم).
  /// بيرجع الإيجار بعد التحديث، وبيرمي Exception لو المعدة مش خارجة.
  Future<Rental> checkIn(int equipmentId) async {
    final d = await db;
    return d.transaction((txn) async {
      final rows = await txn.query(
        'rentals',
        where: 'equipment_id = ? AND return_date IS NULL',
        whereArgs: [equipmentId],
        limit: 1,
      );
      if (rows.isEmpty) throw StateError('المعدة دي مش خارجة');

      final rental = Rental.fromMap(rows.first);
      final now = DateTime.now();
      final hours = now.difference(rental.outDate).inHours;
      final days = (hours / 24).ceil().clamp(1, 100000);
      final total = days * rental.dailyRate;

      await txn.update(
        'rentals',
        {'return_date': now.toIso8601String(), 'total': total},
        where: 'id = ?',
        whereArgs: [rental.id],
      );

      return Rental(
        id: rental.id,
        equipmentId: rental.equipmentId,
        customer: rental.customer,
        outDate: rental.outDate,
        dueDate: rental.dueDate,
        returnDate: now,
        dailyRate: rental.dailyRate,
        total: total,
      );
    });
  }

  Future<List<Rental>> getRentalsForEquipment(int equipmentId) async {
    final d = await db;
    final rows = await d.query(
      'rentals',
      where: 'equipment_id = ?',
      whereArgs: [equipmentId],
      orderBy: 'out_date DESC',
    );
    return rows.map(Rental.fromMap).toList();
  }

  // ---------------- الملخص ----------------

  Future<InventoryStats> getStats() async {
    final d = await db;
    final total =
        Sqflite.firstIntValue(
          await d.rawQuery('SELECT COUNT(*) FROM equipment'),
        ) ??
        0;
    final out =
        Sqflite.firstIntValue(
          await d.rawQuery(
            'SELECT COUNT(DISTINCT equipment_id) FROM rentals WHERE return_date IS NULL',
          ),
        ) ??
        0;
    final late =
        Sqflite.firstIntValue(
          await d.rawQuery(
            'SELECT COUNT(DISTINCT equipment_id) FROM rentals '
            'WHERE return_date IS NULL AND due_date < ?',
            [DateTime.now().toIso8601String()],
          ),
        ) ??
        0;

    return InventoryStats(
      total: total,
      available: total - out,
      out: out,
      late: late,
    );
  }
}
