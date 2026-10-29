import 'dart:async';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:cinema_inventory/equipment.dart';
import 'package:cinema_inventory/inventory_stats.dart';

class CodeAlreadyExistsException implements Exception {
  const CodeAlreadyExistsException();
}

/// Local SQLite storage. The public API (watchAll / watchStats / add / delete)
/// is the same one the screens use, so the storage can be swapped later
/// (e.g. back to Firebase) without touching the UI.
class EquipmentRepository {
  EquipmentRepository._();
  static final EquipmentRepository instance = EquipmentRepository._();

  Database? _db;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'equipment_manager.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE equipment (
          code TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          daily_rate REAL NOT NULL,
          notes TEXT NOT NULL DEFAULT '',
          created_at TEXT NOT NULL,
          is_out INTEGER NOT NULL DEFAULT 0,
          due_date TEXT
        )
      '''),
    );
  }

  Future<List<Equipment>> _fetchAll() async {
    final db = await _database;
    final rows = await db.query('equipment');
    final list = rows.map(Equipment.fromMap).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// Emits the current list, then again after every change.
  Stream<List<Equipment>> watchAll() async* {
    yield await _fetchAll();
    await for (final _ in _changes.stream) {
      yield await _fetchAll();
    }
  }

  Stream<InventoryStats> watchStats() {
    return watchAll().map((list) {
      final out = list.where((e) => e.isOut).length;
      final late = list.where((e) => e.isLate).length;
      return InventoryStats(
        total: list.length,
        available: list.length - out,
        out: out,
        late: late,
      );
    });
  }

  /// Adds the item. Throws [CodeAlreadyExistsException] if the code is taken.
  Future<void> add(Equipment e) async {
    final db = await _database;
    try {
      await db.insert(
        'equipment',
        e.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } on DatabaseException catch (err) {
      if (err.isUniqueConstraintError()) {
        throw const CodeAlreadyExistsException();
      }
      rethrow;
    }
    _changes.add(null);
  }

  Future<void> delete(String code) async {
    final db = await _database;
    await db.delete('equipment', where: 'code = ?', whereArgs: [code]);
    _changes.add(null);
  }

  /// e.g. EQ-K7M2PX (no look-alike characters like 0/O or 1/I)
  static String generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    final suffix = List.generate(
      6,
      (_) => chars[r.nextInt(chars.length)],
    ).join();
    return 'EQ-$suffix';
  }
}
