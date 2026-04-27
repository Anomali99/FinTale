import 'package:sqflite/sqflite.dart';

import '../../../models/wallet_model.dart';

class WalletDao {
  final Database db;

  WalletDao(this.db);

  Future<int> create(WalletModel wallet) async {
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = wallet.toMap();
    data['created_at'] = now;
    data['updated_at'] = now;
    data['deleted_at'] = null;

    return await db.insert('wallets', data);
  }

  Future<List<WalletModel>> readAllActiveData() async {
    final result = await db.query(
      'wallets',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at ASC',
    );

    return result.map((json) => WalletModel.fromMap(json)).toList();
  }

  Future<WalletModel?> readData(int id) async {
    final maps = await db.query(
      'wallets',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return WalletModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(WalletModel wallet) async {
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = wallet.toMap();
    data['updated_at'] = now;

    return await db.update(
      'wallets',
      data,
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<int> softDelete(int id) async {
    int now = DateTime.now().millisecondsSinceEpoch;

    return await db.update(
      'wallets',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
