import 'package:sqflite/sqflite.dart';

import '../../../models/wallet_model.dart';
import '../app_database.dart';

class WalletDao {
  Future<Database> get _database async => await AppDatabase.instance.database;

  Future<int> create(WalletModel wallet) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = wallet.toMap();
    data['created_at'] = now;
    data['updated_at'] = now;
    data['deleted_at'] = null;
    return await database.insert('wallets', data);
  }

  Future<List<WalletModel>> readAllActiveData() async {
    final database = await _database;
    final result = await database.query(
      'wallets',
      where: 'deleted_at IS NULL',
      orderBy: '''
      CASE type
        WHEN 'cash' THEN 1
        WHEN 'bank' THEN 2
        WHEN 'eWallet' THEN 3
        WHEN 'platform' THEN 4
        ELSE 5 
      END ASC, 
      created_at DESC
      ''',
    );

    return result.map((json) => WalletModel.fromMap(json)).toList();
  }

  Future<WalletModel?> readData(int id) async {
    final database = await _database;
    final maps = await database.query(
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
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> data = wallet.toMap();
    data['updated_at'] = now;

    return await database.update(
      'wallets',
      data,
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<int> softDelete(int id) async {
    final database = await _database;
    int now = DateTime.now().millisecondsSinceEpoch;

    return await database.update(
      'wallets',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
