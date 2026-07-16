import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fintale.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount TEXT NOT NULL,
        reserved_amount TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        has_dividend INTEGER NOT NULL,
        is_emergency INTEGER NOT NULL,
        unit_name TEXT NOT NULL,
        invested TEXT NOT NULL,
        value TEXT NOT NULL,
        unit TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount TEXT NOT NULL,
        paid_amount TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE receivables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        borrower_name TEXT NOT NULL,
        title TEXT NOT NULL,
        amount TEXT NOT NULL,
        paid_amount TEXT NOT NULL,
        date_timestamp INTEGER NOT NULL,
        target_date INTEGER,
        is_reminder_active INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debt_id INTEGER UNIQUE,
        title TEXT NOT NULL,
        amount TEXT NOT NULL,
        type TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        next_due_date INTEGER,
        day_name TEXT,
        day INTEGER,
        month INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,

        FOREIGN KEY (debt_id) REFERENCES debts (id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wallet_id INTEGER,
        debt_id INTEGER,
        bill_id INTEGER,
        receivable_id INTEGER,
        assets_id INTEGER,
        target_id INTEGER,
        title TEXT NOT NULL,
        amount TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        date_timestamp INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,

        FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE RESTRICT,
        FOREIGN KEY (debt_id) REFERENCES debts (id) ON DELETE RESTRICT,
        FOREIGN KEY (bill_id) REFERENCES bills (id) ON DELETE RESTRICT,
        FOREIGN KEY (receivable_id) REFERENCES receivables (id) ON DELETE RESTRICT,
        FOREIGN KEY (assets_id) REFERENCES assets (id) ON DELETE RESTRICT,
        FOREIGN KEY (target_id) REFERENCES wallets (id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount TEXT NOT NULL,
        flow TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,

        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<Map<String, dynamic>> exportAllData() async {
    final db = await instance.database;
    final Map<String, dynamic> databaseData = {};

    List<String> tables = [
      'wallets',
      'assets',
      'debts',
      'receivables',
      'bills',
      'transactions',
      'transaction_details',
    ];

    for (String table in tables) {
      final List<Map<String, dynamic>> data = await db.query(table);
      databaseData[table] = data;
    }

    return databaseData;
  }

  Future<bool> importDatabase(Map<String, dynamic> databaseData) async {
    final db = await instance.database;
    try {
      await db.transaction((txn) async {
        List<String> deleteOrder = [
          'transaction_details',
          'transactions',
          'bills',
          'receivables',
          'debts',
          'assets',
          'wallets',
        ];

        for (String table in deleteOrder) {
          await txn.delete(table);
        }

        List<String> insertOrder = [
          'wallets',
          'assets',
          'debts',
          'receivables',
          'bills',
          'transactions',
          'transaction_details',
        ];

        for (String table in insertOrder) {
          if (databaseData.containsKey(table)) {
            List<dynamic> rows = databaseData[table];
            for (var row in rows) {
              await txn.insert(table, Map<String, dynamic>.from(row));
            }
          }
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fintale.db');

    if (_database != null) {
      await _database!.close();
    }
    await deleteDatabase(path);

    _database = null;
  }
}
