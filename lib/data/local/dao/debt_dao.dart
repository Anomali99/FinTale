import 'package:sqflite/sqflite.dart';

import '../../../models/bill_model.dart';
import '../../../models/debt_model.dart';
import '../app_database.dart';

class DebtDao {
  Future<Database> get _database async => await AppDatabase.instance.database;

  Future<int> create(DebtModel debt) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> parentData = debt.toMap();
    parentData['created_at'] = now;
    parentData['updated_at'] = now;
    parentData['deleted_at'] = null;

    int id = await database.insert('debts', parentData);

    BillModel? bill = debt.bill;
    if (bill != null) {
      Map<String, dynamic> childData = bill.toMap();
      childData['debt_id'] = id;
      childData['created_at'] = now;
      childData['updated_at'] = now;
      childData['deleted_at'] = null;

      await database.insert('bills', childData);
    }

    return id;
  }

  Future<List<DebtModel>> readAllActiveData() async {
    final database = await _database;
    final result = await database.query(
      'debts',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at ASC',
    );

    return result.map((json) => DebtModel.fromMap(json)).toList();
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

  Future<int> update(DebtModel debt) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> parentData = debt.toMap();
    parentData['updated_at'] = now;

    BillModel? bill = debt.bill;

    if (bill != null) {
      if (bill.id == null) {
        Map<String, dynamic> childData = bill.toMap();
        childData['created_at'] = now;
        childData['updated_at'] = now;
        childData['deleted_at'] = null;

        await database.insert('bills', childData);
      } else {
        Map<String, dynamic> childData = bill.toMap();
        childData['updated_at'] = now;

        await database.update(
          'bills',
          parentData,
          where: 'id = ?',
          whereArgs: [bill.id],
        );
      }
    }

    return await database.update(
      'debts',
      parentData,
      where: 'id = ?',
      whereArgs: [debt.id],
    );
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
