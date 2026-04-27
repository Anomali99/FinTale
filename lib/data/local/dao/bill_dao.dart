import 'package:sqflite/sqflite.dart';

import '../../../models/bill_model.dart';

class BillDao {
  final Database db;

  BillDao(this.db);

  Future<int> create(BillModel bill) async {
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = bill.toMap();
    data['created_at'] = now;
    data['updated_at'] = now;
    data['deleted_at'] = null;

    return await db.insert('wallets', data);
  }

  Future<List<BillModel>> readAllActiveData() async {
    final result = await db.query(
      'bills',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at ASC',
    );

    return result.map((json) => BillModel.fromMap(json)).toList();
  }

  Future<BillModel?> readData(int id) async {
    final maps = await db.query(
      'bills',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BillModel.fromMap(maps.first);
    }
    return null;
  }

  Future<BillModel?> readDataByDebt(int id) async {
    final maps = await db.query(
      'bills',
      where: 'debt_id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BillModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(BillModel bill) async {
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = bill.toMap();
    data['updated_at'] = now;

    return await db.update(
      'bills',
      data,
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> softDelete(int id) async {
    int now = DateTime.now().millisecondsSinceEpoch;

    return await db.update(
      'bills',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
