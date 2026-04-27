import 'package:sqflite/sqflite.dart';

import '../../../models/assets_model.dart';

class AssetDao {
  final Database db;

  AssetDao(this.db);

  Future<int> create(AssetsModel asset) async {
    int now = DateTime.now().microsecondsSinceEpoch;

    Map<String, dynamic> data = asset.toMap();
    data['created_at'] = now;
    data['updated_at'] = now;
    data['deleted_at'] = null;

    return await db.insert('assets', data);
  }

  Future<List<AssetsModel>> readAllActiveData() async {
    final result = await db.query(
      'assets',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at ASC',
    );

    return result.map((json) => AssetsModel.fromMap(json)).toList();
  }

  Future<AssetsModel?> readData(int id) async {
    final maps = await db.query(
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
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = asset.toMap();
    data['updated_at'] = now;

    return await db.update(
      'assets',
      data,
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  Future<int> softDelete(int id) async {
    int now = DateTime.now().millisecondsSinceEpoch;

    return await db.update(
      'assets',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
