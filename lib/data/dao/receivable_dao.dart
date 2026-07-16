import 'package:sqflite/sqflite.dart';

import '../../models/receivable_model.dart';
import '../app_database.dart';

class ReceivableDao {
  Future<Database> get _database async => await AppDatabase.instance.database;

  Future<int> create(ReceivableModel receivable) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = receivable.toMap();
    data['created_at'] = now;
    data['updated_at'] = now;
    data['deleted_at'] = null;
    return await database.insert('receivables', data);
  }

  Future<List<ReceivableModel>> readAllActiveData() async {
    final database = await _database;
    final result = await database.query(
      'receivables',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at DESC',
    );

    return result.map((json) => ReceivableModel.fromMap(json)).toList();
  }

  Future<int> update(ReceivableModel receivable) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = receivable.toMap();
    data['updated_at'] = now;

    return await database.update(
      'receivables',
      data,
      where: 'id = ?',
      whereArgs: [receivable.id],
    );
  }

  Future<void> updateMultiple(List<ReceivableModel> receivables) async {
    final database = await _database;
    final batch = database.batch();
    int now = DateTime.now().millisecondsSinceEpoch;

    for (var receivable in receivables) {
      Map<String, dynamic> data = receivable.toMap();
      data['updated_at'] = now;

      batch.update(
        'receivables',
        data,
        where: 'id = ?',
        whereArgs: [receivable.id],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<int> softDelete(int id) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    return await database.update(
      'receivables',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
