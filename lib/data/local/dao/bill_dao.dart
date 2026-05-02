import 'package:sqflite/sqflite.dart';

import '../../../models/bill_model.dart';
import '../app_database.dart';

class BillDao {
  Future<Database> get _database async => await AppDatabase.instance.database;

  Future<int> create(BillModel bill) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = bill.toMap();
    data['created_at'] = now;
    data['updated_at'] = now;
    data['deleted_at'] = null;

    return await database.insert('wallets', data);
  }

  Future<List<BillModel>> readAllActiveData() async {
    final database = await _database;
    final result = await database.query(
      'bills',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at ASC',
    );

    return result.map((json) => BillModel.fromMap(json)).toList();
  }

  Future<BillModel?> readData(int id) async {
    final database = await _database;
    final maps = await database.query(
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
    final database = await _database;
    final maps = await database.query(
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
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = bill.toMap();
    data['updated_at'] = now;

    return await database.update(
      'bills',
      data,
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> softDelete(int id) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    return await database.update(
      'bills',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
