import 'package:decimal/decimal.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/utils/enum_types.dart';
import '../../models/bill_model.dart';
import '../../models/debt_model.dart';
import '../app_database.dart';

class DebtDao {
  Future<Database> get _database async => await AppDatabase.instance.database;

  Future<List<int>> create(DebtModel debt) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> parentData = debt.toMap();
    parentData['created_at'] = now;
    parentData['updated_at'] = now;
    parentData['deleted_at'] = null;

    return await database.transaction<List<int>>((txn) async {
      int id = await txn.insert('debts', parentData);

      int? billId;
      BillModel? bill = debt.bill;
      if (bill != null) {
        Map<String, dynamic> childData = bill.toMap();
        childData['debt_id'] = id;
        childData['created_at'] = now;
        childData['updated_at'] = now;
        childData['deleted_at'] = null;

        billId = await txn.insert('bills', childData);
      }

      return [id, billId ?? 0];
    });
  }

  Future<List<DebtModel>> readAllActiveData() async {
    final database = await _database;
    final result = await database.rawQuery('''
    SELECT
      d.*,
      b.id AS b_id,
      b.debt_id AS b_debt_id,
      b.title AS b_title,
      b.amount AS b_amount,
      b.type AS b_type,
      b.is_active AS b_is_active,
      b.next_due_date AS b_next_due_date,
      b.day_name AS b_day_name,
      b.day AS b_day,
      b.month AS b_month
    FROM debts d
    LEFT JOIN bills b ON b.debt_id = d.id AND b.deleted_at IS NULL
    WHERE d.deleted_at IS NULL
    ORDER BY d.created_at ASC
    ''');

    return result.map((row) {
      BillModel? bill;
      if (row['b_id'] != null) {
        bill = BillModel(
          id: row['b_id'] as int?,
          debtId: row['b_debt_id'] as int?,
          title: (row['b_title'] ?? '') as String,
          amount: Decimal.parse((row['b_amount'] ?? '0').toString()),
          type: TimeType.values.firstWhere(
            (e) => e.name == row['b_type'],
            orElse: () => TimeType.monthly,
          ),
          isActive: (row['b_is_active'] == 1),
          nextDueDate: row['b_next_due_date'] as int?,
          dayName: row['b_day_name'] != null
              ? DayName.values.firstWhere(
                  (e) => e.name == row['b_day_name'],
                  orElse: () => DayName.monday,
                )
              : null,
          day: row['b_day'] as int?,
          month: row['b_month'] as int?,
        );
      }
      return DebtModel.fromMap(row, bill: bill);
    }).toList();
  }

  Future<DebtModel?> readData(int id) async {
    final database = await _database;
    final maps = await database.query(
      'debts',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DebtModel.fromMap(maps.first);
    }
    return null;
  }

  Future<DebtModel?> readDataWithChild(int id) async {
    final database = await _database;
    final parentMaps = await database.query(
      'debts',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (parentMaps.isEmpty) return null;

    final childMaps = await database.query(
      'bills',
      where: 'debt_id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    return DebtModel.fromMap(
      parentMaps.first,
      bill: childMaps.isNotEmpty ? BillModel.fromMap(childMaps.first) : null,
    );
  }

  Future<List<int>> update(DebtModel debt) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> parentData = debt.toMap();
    parentData['updated_at'] = now;

    int? billId;
    BillModel? bill = debt.bill;

    if (bill != null) {
      if (bill.id == null) {
        Map<String, dynamic> childData = bill.toMap();
        childData['created_at'] = now;
        childData['updated_at'] = now;
        childData['deleted_at'] = null;

        billId = await database.insert('bills', childData);
      } else {
        billId = bill.id;
        Map<String, dynamic> childData = bill.toMap();
        childData['updated_at'] = now;

        await database.update(
          'bills',
          childData,
          where: 'id = ?',
          whereArgs: [bill.id],
        );
      }
    }
    int id = await database.update(
      'debts',
      parentData,
      where: 'id = ?',
      whereArgs: [debt.id],
    );
    return [id, billId ?? 0];
  }

  Future<int> softDelete(int id) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    return await database.update(
      'debts',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
