import 'package:sqflite/sqflite.dart';

import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../app_database.dart';

class TransactionDao {
  Future<Database> get _database async => await AppDatabase.instance.database;

  Future<int> create(TransactionModel transaction) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> parentData = transaction.toMap();
    parentData['created_at'] = now;
    parentData['updated_at'] = now;
    parentData['deleted_at'] = null;

    int id = await database.insert('transactions', parentData);

    for (TransactionDetailModel detail in transaction.detailTransaction) {
      Map<String, dynamic> childData = detail.toMap(id);
      childData['created_at'] = now;
      childData['updated_at'] = now;
      childData['deleted_at'] = null;

      await database.insert('transaction_details', childData);
    }

    return id;
  }

  Future<List<TransactionModel>> readAllActiveData() async {
    final database = await _database;
    final result = await database.rawQuery('''
    SELECT
      t.*,
      (SELECT category FROM transaction_details d WHERE d.transaction_id = t.id ORDER BY day ASC LIMIT 1) AS icon
    FROM transactions t
    WHERE d.deleted_at IS NULL
    ORDER BY d.created_at DESC
    ''');

    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<TransactionModel?> readData(int id) async {
    final database = await _database;
    final maps = await database.query(
      'transactions',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  Future<TransactionModel?> readDataWithChild(int id) async {
    final database = await _database;
    final parentMaps = await database.query(
      'transactions',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (parentMaps.isEmpty) return null;

    final childMaps = await database.query(
      'transaction_details',
      where: 'transaction_id = ?',
      whereArgs: [id],
    );

    List<TransactionDetailModel> childList = childMaps.map((map) {
      return TransactionDetailModel.fromMap(map);
    }).toList();

    return TransactionModel.fromMap(parentMaps.first, details: childList);
  }

  Future<List<TransactionModel>> getFilteredData({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? walletId,
    List<StatusType>? status,
    List<TransactionType>? type,
  }) async {
    final database = await _database;
    String whereClause = 't.deleted_at IS NULL';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause += ' AND t.date_timestamp BETWEEN ? AND ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    if (walletId != null && walletId.isNotEmpty) {
      final placeholders = List.filled(walletId.length, '?').join(',');
      whereClause += ' AND t.wallet_id IN ($placeholders)';
      whereArgs.addAll(walletId);
    }

    if (status != null && status.isNotEmpty) {
      final placeholders = List.filled(status.length, '?').join(',');
      whereClause += ' AND t.status IN ($placeholders)';

      whereArgs.addAll(status.map((s) => s.name));
    }

    if (type != null && type.isNotEmpty) {
      final placeholders = List.filled(type.length, '?').join(',');
      whereClause += ' AND t.type IN ($placeholders)';
      whereArgs.addAll(type.map((t) => t.name));
    }

    final sql =
        '''
      SELECT 
        t.*,
        (SELECT category FROM transaction_details d WHERE d.transaction_id = t.id ORDER BY d.id ASC LIMIT 1) AS icon
      FROM transactions t
      WHERE $whereClause
      ORDER BY t.date_timestamp DESC
    ''';

    final result = await database.rawQuery(sql, whereArgs);

    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> update(TransactionModel transaction) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> parentData = transaction.toMap();
    parentData['updated_at'] = now;

    for (TransactionDetailModel detail in transaction.detailTransaction) {
      if (detail.id == null) {
        Map<String, dynamic> childData = detail.toMap(transaction.id ?? 0);
        childData['created_at'] = now;
        childData['updated_at'] = now;
        childData['deleted_at'] = null;

        await database.insert('transaction_details', childData);
      } else {
        Map<String, dynamic> childData = detail.toMap(transaction.id ?? 0);
        childData['updated_at'] = now;

        await database.update(
          'transaction_details',
          parentData,
          where: 'id = ?',
          whereArgs: [detail.id],
        );
      }
    }

    return await database.update(
      'transactions',
      parentData,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> softDelete(int id) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    return await database.update(
      'transactions',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
