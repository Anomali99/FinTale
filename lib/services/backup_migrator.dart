import 'package:decimal/decimal.dart';

/// Handles migration of backup data across different schema versions.
///
/// Schema versions:
///   1 - Original schema (wallets, assets, debts, bills, transactions,
///       transaction_details). No receivables table, no receivable_id
///       in transactions.
///   2 - Added receivables table, added receivable_id column in
///       transactions, added DB indices.
///   3 - Wallet pockets: added parent_id, is_savings, is_emergency
///       columns to wallets. Removed reserved_amount. Wallets with
///       reserved_amount > 0 get a 'Tabungan' savings pocket.
///
/// This migrator ensures that backup files from any known schema
/// version can be loaded into the current app version.
class BackupMigrator {
  static const int currentSchemaVersion = 3;

  /// Column whitelist for each table in the current schema.
  /// Used to strip unknown/removed columns from old backups and
  /// prevent insert failures.
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

  /// Detects the schema version from backup metadata.
  ///
  /// If the backup has an explicit `schema_version`, use it.
  /// Otherwise, infer from the data structure:
  ///   - No `receivables` key in database → schema 1
  ///   - Has `receivables` key but wallets have reserved_amount → schema 2
  ///   - Has parent_id in wallets → schema 3
  static int detectSchemaVersion(Map<String, dynamic> backupData) {
    final metadata = backupData['metadata'] as Map<String, dynamic>?;

    // Explicit schema version takes priority
    if (metadata != null && metadata.containsKey('schema_version')) {
      return metadata['schema_version'] as int;
    }

    final database = backupData['database'] as Map<String, dynamic>?;
    if (database == null) return 1;

    // Heuristic: check wallet rows for parent_id (schema 3)
    if (database.containsKey('wallets')) {
      final List<dynamic> walletRows = database['wallets'] as List<dynamic>;
      if (walletRows.isNotEmpty) {
        final firstRow = walletRows[0] as Map;
        if (firstRow.containsKey('parent_id')) {
          return 3;
        }
      }
    }

    // Heuristic: receivables table was added in schema 2
    if (database.containsKey('receivables')) {
      return 2;
    }

    return 1;
  }

  /// Migrates backup data to the current schema version.
  ///
  /// Returns a new Map with the migrated data. The original data
  /// is not modified.
  static Map<String, dynamic> migrate(Map<String, dynamic> backupData) {
    int version = detectSchemaVersion(backupData);

    // Deep-copy to avoid mutating the original
    Map<String, dynamic> migrated = _deepCopy(backupData);

    // Apply migrations sequentially
    if (version < 2) {
      migrated = _migrateV1ToV2(migrated);
      version = 2;
    }

    if (version < 3) {
      migrated = _migrateV2ToV3(migrated);
      version = 3;
    }

    // Stamp the current schema version
    migrated['metadata'] ??= {};
    (migrated['metadata'] as Map<String, dynamic>)['schema_version'] =
        currentSchemaVersion;

    return migrated;
  }

  /// Sanitizes each row so it only contains columns the current
  /// table schema expects. This prevents "table X has no column
  /// named Y" errors from sqflite.
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

  /// Ensures the user data has all required fields with sensible
  /// defaults so UserModel.fromJson won't crash on old backups.
  static Map<String, dynamic> sanitizeUserData(Map<String, dynamic> userData) {
    final Map<String, dynamic> sanitized = Map<String, dynamic>.from(userData);

    // Core fields
    sanitized['uid'] ??= '';
    sanitized['name'] ??= '';
    sanitized['email'] ??= '';
    sanitized['title'] ??= 'noviceSaver';
    sanitized['level'] ??= 1;
    sanitized['xp'] ??= 0;

    // Budget sub-object
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

    // Allocation sub-object
    sanitized['allocation'] ??= {};
    final allocation = Map<String, dynamic>.from(
      sanitized['allocation'] as Map? ?? {},
    );
    allocation['skills'] ??= {};
    allocation['pending'] ??= [];
    sanitized['allocation'] = allocation;

    // Progress sub-object
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
    // These keys are intentionally nullable; ensure they exist
    progress.putIfAbsent('last_login_date', () => null);
    progress.putIfAbsent('current_week_id', () => null);
    progress.putIfAbsent('current_month_id', () => null);
    sanitized['progress'] = progress;

    return sanitized;
  }

  // -- Private migration steps --

  /// v1 → v2: Add empty receivables list, add receivable_id to
  /// transactions rows.
  static Map<String, dynamic> _migrateV1ToV2(Map<String, dynamic> backupData) {
    final database = backupData['database'] as Map<String, dynamic>? ?? {};

    // Add empty receivables table if missing
    database['receivables'] ??= <Map<String, dynamic>>[];

    // Add receivable_id = null to each transaction row
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

  /// v2 → v3: Add parent_id, is_savings, is_emergency to wallets.
  /// Migrate reserved_amount > 0 into savings pocket rows.
  /// Remove reserved_amount from all wallet rows.
  static Map<String, dynamic> _migrateV2ToV3(Map<String, dynamic> backupData) {
    final database = backupData['database'] as Map<String, dynamic>? ?? {};

    if (database.containsKey('wallets')) {
      final List<dynamic> walletRows = database['wallets'];
      final List<Map<String, dynamic>> newPockets = [];

      // Find the max id to generate new pocket ids
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
          // Create a savings pocket
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

          // Update parent wallet amount
          row['amount'] = newParentAmount.toString();
        }

        // Add new columns with defaults
        row['parent_id'] = row['parent_id']; // null for existing rows
        row['is_savings'] = row['is_savings'] ?? 0;
        row['is_emergency'] = row['is_emergency'] ?? 0;

        // Remove reserved_amount
        row.remove('reserved_amount');

        walletRows[i] = row;
      }

      // Append new pocket rows
      walletRows.addAll(newPockets);
    }

    backupData['database'] = database;
    return backupData;
  }

  /// Creates a deep copy of the backup data so we don't mutate
  /// the caller's map.
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
