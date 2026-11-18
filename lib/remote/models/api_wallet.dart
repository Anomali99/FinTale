// DTO dompet untuk request ke server FinTale.
// Berbeda dari WalletModel (domain DB) — hanya berisi field yang dikontrakkan.

import '../../../models/wallet_model.dart';

class ApiWallet {
  final int id;
  final String name;

  /// Nilai: cash, bank, eWallet, platform (nama enum WalletType).
  final String type;

  const ApiWallet({required this.id, required this.name, required this.type});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
  };

  /// Membuat ApiWallet dari WalletModel aplikasi.
  /// Wallet yang belum disimpan (id null) diabaikan — gunakan [fromWalletModelOrNull].
  factory ApiWallet.fromWalletModel(WalletModel wallet) {
    assert(wallet.id != null, 'WalletModel harus sudah tersimpan (id tidak null)');
    return ApiWallet(
      id: wallet.id!,
      name: wallet.name,
      type: wallet.type.name,
    );
  }

  /// Mengembalikan null jika wallet belum memiliki id (belum tersimpan).
  static ApiWallet? fromWalletModelOrNull(WalletModel wallet) {
    if (wallet.id == null) return null;
    return ApiWallet.fromWalletModel(wallet);
  }
}
