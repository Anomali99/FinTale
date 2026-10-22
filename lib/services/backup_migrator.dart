import 'package:decimal/decimal.dart';

class BackupMigrator {
  static const int currentSchemaVersion = 3;

  static const Map<String, List<String>> _tableColumns = {
    'wallets': [
      'id',
      'name',
      'amount',
      'type',
      'parent_id',
      'is_savings',
      'is_emergency',
      'created_at',
      'updated_at',
      'deleted_at',
    ],
    'assets': [
      'id',
      'name',
      'type',
      'category',
      'has_dividend',
      'is_emergency',
      'unit_name',
      'invested',
      'value',
      'unit',
      'created_at',
      'updated_at',
      'deleted_at',
    ],
    'debts': [
      'id',
      'title',
      'amount',
      'paid_amount',
      'type',
      'created_at',
      'updated_at',
      'deleted_at',
    ],
    'receivables': [
      'id',
      'borrower_name',
      'title',
      'amount',
      'paid_amount',
      'date_timestamp',
      'target_date',
      'is_reminder_active',
      'created_at',
      'updated_at',
      'deleted_at',
    ],
    'bills': [
      'id',
      'debt_id',
      'title',
      'amount',
      'type',
      'is_active',
      'next_due_date',
      'day_name',
      'day',
      'month',
      'created_at',
      'updated_at',
      'deleted_at',
    ],
    'transactions': [
      'id',
      'wallet_id',
      'debt_id',
      'bill_id',
      'receivable_id',
      'assets_id',
      'target_id',
      'title',
      'amount',
      'type',
      'status',
      'date_timestamp',
      'created_at',
      'updated_at',
      'deleted_at',
    ],
    'transaction_details': [
      'id',
      'transaction_id',
      'title',
      'amount',
      'flow',
      'category',
      'created_at',
      'updated_at',
      'deleted_at',
    ],
  };

  static int detectSchemaVersion(Map<String, dynamic> backupData) {
    final metadata = backupData['metadata'] as Map<String, dynamic>?;

    if (metadata != null && metadata.containsKey('schema_version')) {
      return metadata['schema_version'] as int;
    }

    final database = backupData['database'] as Map<String, dynamic>?;
    if (database == null) return 1;

    if (database.containsKey('wallets')) {
      final List<dynamic> walletRows = database['wallets'] as List<dynamic>;
      if (walletRows.isNotEmpty) {
        final firstRow = walletRows[0] as Map;
        if (firstRow.containsKey('parent_id')) {
          return 3;
        }
      }
    }

    if (database.containsKey('receivables')) {
      return 2;
    }

    return 1;
  }

  static Map<String, dynamic> migrate(Map<String, dynamic> backupData) {
    int version = detectSchemaVersion(backupData);

    Map<String, dynamic> migrated = _deepCopy(backupData);

    if (version < 2) {
      migrated = _migrateV1ToV2(migrated);
      version = 2;
    }

    if (version < 3) {
      migrated = _migrateV2ToV3(migrated);
      version = 3;
    }

    migrated['metadata'] ??= {};
    (migrated['metadata'] as Map<String, dynamic>)['schema_version'] =
        currentSchemaVersion;

    return migrated;
  }

  static Map<String, dynamic> sanitizeDatabase(
    Map<String, dynamic> databaseData,
  ) {
    final Map<String, dynamic> sanitized = {};

    for (final table in _tableColumns.keys) {
      if (!databaseData.containsKey(table)) {
        continue;
      }

      final allowedColumns = _tableColumns[table]!.toSet();
      final List<dynamic> rows = databaseData[table] as List<dynamic>;
      final List<Map<String, dynamic>> cleanRows = [];

      for (final row in rows) {
        final Map<String, dynamic> original = Map<String, dynamic>.from(
          row as Map,
        );
        original.removeWhere((key, _) => !allowedColumns.contains(key));
        cleanRows.add(original);
      }

      sanitized[table] = cleanRows;
    }

    return sanitized;
  }

  static Map<String, dynamic> sanitizeUserData(Map<String, dynamic> userData) {
    final Map<String, dynamic> sanitized = Map<String, dynamic>.from(userData);

    sanitized['uid'] ??= '';
    sanitized['name'] ??= '';
    sanitized['email'] ??= '';
    sanitized['title'] ??= 'noviceSaver';
    sanitized['level'] ??= 1;
    sanitized['xp'] ??= 0;

    sanitized['budget'] ??= {};
    final budget = Map<String, dynamic>.from(sanitized['budget'] as Map? ?? {});
    budget['base_daily_limit'] ??= '0';
    budget['daily_penalty'] ??= '0';
    budget['current_penalty'] ??= '0';
    budget['today_usage'] ??= '0';
    budget['emergency_amount'] ??= '0';
    budget['emergency_total'] ??= '0';
    budget['last_active_date'] ??= 0;
    budget['is_free_debt'] ??= true;
    sanitized['budget'] = budget;

    sanitized['allocation'] ??= {};
    final allocation = Map<String, dynamic>.from(
      sanitized['allocation'] as Map? ?? {},
    );
    allocation['skills'] ??= {};
    allocation['pending'] ??= [];
    sanitized['allocation'] = allocation;

    sanitized['progress'] ??= {};
    final progress = Map<String, dynamic>.from(
      sanitized['progress'] as Map? ?? {},
    );
    progress['daily_transaction_count'] ??= 0;
    progress['is_daily_budget_claimed'] ??= false;
    progress['weekly_login_days'] ??= 0;
    progress['weekly_budget_days'] ??= 0;
    progress['is_weekly_checkIn_claimed'] ??= false;
    progress['is_weekly_budget_claimed'] ??= false;
    progress['is_monthly_debt_claimed'] ??= false;
    progress['is_monthly_review_claimed'] ??= false;
    progress['is_first_transaction_claimed'] ??= false;
    progress['wallet_created_count'] ??= 0;
    progress['is_allocationSet_claimed'] ??= false;

    progress.putIfAbsent('last_login_date', () => null);
    progress.putIfAbsent('current_week_id', () => null);
    progress.putIfAbsent('current_month_id', () => null);
    sanitized['progress'] = progress;

    return sanitized;
  }

  static Map<String, dynamic> _migrateV1ToV2(Map<String, dynamic> backupData) {
    final database = backupData['database'] as Map<String, dynamic>? ?? {};

    database['receivables'] ??= <Map<String, dynamic>>[];

    if (database.containsKey('transactions')) {
      final List<dynamic> transactions = database['transactions'];
      for (int i = 0; i < transactions.length; i++) {
        final row = Map<String, dynamic>.from(transactions[i] as Map);
        row.putIfAbsent('receivable_id', () => null);
        transactions[i] = row;
      }
    }

    backupData['database'] = database;
    return backupData;
  }

  static Map<String, dynamic> _migrateV2ToV3(Map<String, dynamic> backupData) {
    final database = backupData['database'] as Map<String, dynamic>? ?? {};

    if (database.containsKey('wallets')) {
      final List<dynamic> walletRows = database['wallets'];
      final List<Map<String, dynamic>> newPockets = [];

      int maxId = 0;
      for (final row in walletRows) {
        final Map<String, dynamic> wallet = Map<String, dynamic>.from(
          row as Map,
        );
        final id = wallet['id'] as int? ?? 0;
        if (id > maxId) maxId = id;
      }

      int now = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < walletRows.length; i++) {
        final row = Map<String, dynamic>.from(walletRows[i] as Map);

        final String reservedStr = (row['reserved_amount'] ?? '0').toString();
        final Decimal reserved = Decimal.parse(reservedStr);

        if (reserved > Decimal.zero) {
          maxId++;
          final Decimal currentAmount = Decimal.parse(
            (row['amount'] ?? '0').toString(),
          );
          final Decimal newParentAmount = currentAmount - reserved;

          newPockets.add({
            'id': maxId,
            'name': 'Tabungan',
            'amount': reservedStr,
            'type': row['type'],
            'parent_id': row['id'],
            'is_savings': 1,
            'is_emergency': 0,
            'created_at': now,
            'updated_at': now,
            'deleted_at': null,
          });

          row['amount'] = newParentAmount.toString();
        }

        row['parent_id'] = row['parent_id'];
        row['is_savings'] = row['is_savings'] ?? 0;
        row['is_emergency'] = row['is_emergency'] ?? 0;

        row.remove('reserved_amount');

        walletRows[i] = row;
      }

      walletRows.addAll(newPockets);
    }

    backupData['database'] = database;
    return backupData;
  }

  static Map<String, dynamic> _deepCopy(Map<String, dynamic> source) {
    return source.map((key, value) {
      if (value is Map) {
        return MapEntry(key, _deepCopy(Map<String, dynamic>.from(value)));
      } else if (value is List) {
        return MapEntry(key, _deepCopyList(value));
      }
      return MapEntry(key, value);
    });
  }

  static List<dynamic> _deepCopyList(List<dynamic> source) {
    return source.map((item) {
      if (item is Map) {
        return _deepCopy(Map<String, dynamic>.from(item));
      } else if (item is List) {
        return _deepCopyList(item);
      }
      return item;
    }).toList();
  }
}
