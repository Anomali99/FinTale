import 'package:sqflite/sqflite.dart';

import '../../../models/assets_model.dart';
import '../app_database.dart';

class AssetDao {
  Future<Database> get _database async => await AppDatabase.instance.database;

  Future<int> create(AssetsModel asset) async {
    final database = await _database;
    int now = DateTime.now().microsecondsSinceEpoch;

    Map<String, dynamic> data = asset.toMap();
    data['created_at'] = now;
    data['updated_at'] = now;
    data['deleted_at'] = null;

    return await database.insert('assets', data);
  }

  Future<List<AssetsModel>> readAllActiveData() async {
    final database = await _database;
    final result = await database.query(
      'assets',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at ASC',
    );

    return result.map((json) => AssetsModel.fromMap(json)).toList();
  }

  Future<AssetsModel?> readData(int id) async {
    final database = await _database;
    final maps = await database.query(
      'assets',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AssetsModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(AssetsModel asset) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = asset.toMap();
    data['updated_at'] = now;

    return await database.update(
      'assets',
      data,
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  Future<int> softDelete(int id) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    return await database.update(
      'assets',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
