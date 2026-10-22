import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../services/backup_migrator.dart';

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

    return await openDatabase(
      path,
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount TEXT NOT NULL,
        type TEXT NOT NULL,
        parent_id INTEGER,
        is_savings INTEGER NOT NULL DEFAULT 0,
        is_emergency INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,

        FOREIGN KEY (parent_id) REFERENCES wallets (id) ON DELETE CASCADE
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

    await _createIndices(db);
  }

  Future _createIndices(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_wallet ON transactions (wallet_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions (date_timestamp);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_deleted ON transactions (deleted_at);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_trans_details_parent ON transaction_details (transaction_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_bills_debt ON bills (debt_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_receivables_deleted ON receivables (deleted_at);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_wallets_parent ON wallets (parent_id);',
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createIndices(db);
    }
    if (oldVersion < 3) {
      await _migrateV2ToV3(db);
    }
  }

  Future _migrateV2ToV3(Database db) async {
    await db.execute('ALTER TABLE wallets ADD COLUMN parent_id INTEGER;');
    await db.execute(
      'ALTER TABLE wallets ADD COLUMN is_savings INTEGER NOT NULL DEFAULT 0;',
    );
    await db.execute(
      'ALTER TABLE wallets ADD COLUMN is_emergency INTEGER NOT NULL DEFAULT 0;',
    );

    final walletsWithReserved = await db.rawQuery(
      "SELECT id, name, type, reserved_amount, created_at FROM wallets "
      "WHERE CAST(reserved_amount AS REAL) > 0 AND deleted_at IS NULL",
    );

    int now = DateTime.now().millisecondsSinceEpoch;
    for (final row in walletsWithReserved) {
      await db.insert('wallets', {
        'name': 'Tabungan',
        'amount': row['reserved_amount'],
        'type': row['type'],
        'parent_id': row['id'],
        'is_savings': 1,
        'is_emergency': 0,
        'created_at': now,
        'updated_at': now,
        'deleted_at': null,
      });
    }

    for (final row in walletsWithReserved) {
      final int walletId = row['id'] as int;
      final Decimal amount = Decimal.parse((row['amount'] ?? '0').toString());
      final Decimal reserved = Decimal.parse(
        (row['reserved_amount'] ?? '0').toString(),
      );
      final String newAmount = (amount - reserved).toString();
      await db.rawUpdate('UPDATE wallets SET amount = ? WHERE id = ?', [
        newAmount,
        walletId,
      ]);
    }

    await db.execute('PRAGMA foreign_keys = OFF;');

    await db.execute('''
      CREATE TABLE wallets_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount TEXT NOT NULL,
        type TEXT NOT NULL,
        parent_id INTEGER,
        is_savings INTEGER NOT NULL DEFAULT 0,
        is_emergency INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,

        FOREIGN KEY (parent_id) REFERENCES wallets_new (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      INSERT INTO wallets_new (id, name, amount, type, parent_id, is_savings, is_emergency, created_at, updated_at, deleted_at)
      SELECT id, name, amount, type, parent_id, is_savings, is_emergency, created_at, updated_at, deleted_at
      FROM wallets
    ''');

    await db.execute('DROP TABLE wallets');
    await db.execute('ALTER TABLE wallets_new RENAME TO wallets');

    await db.execute('PRAGMA foreign_keys = ON;');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_wallets_parent ON wallets (parent_id);',
    );
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
      final Map<String, dynamic> safeData = BackupMigrator.sanitizeDatabase(
        databaseData,
      );

      await db.execute('PRAGMA foreign_keys = OFF;');

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
          if (safeData.containsKey(table)) {
            List<dynamic> rows = safeData[table];
            for (var row in rows) {
              await txn.insert(table, Map<String, dynamic>.from(row));
            }
          }
        }
      });

      await db.execute('PRAGMA foreign_keys = ON;');

      return true;
    } catch (e, stackTrace) {
      try {
        await db.execute('PRAGMA foreign_keys = ON;');
      } catch (_) {}
      debugPrint("[APP_DATABASE] Import database failed: $e\n$stackTrace");
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
