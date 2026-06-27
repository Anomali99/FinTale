import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';
import 'gamification_dict.dart';
import 'ui_dict.dart';

class ScreenDict {
  static const String walletName = 'Nama Dompet';
  static const String walletType = 'Jenis Dompet';
  static const String homePenalty = 'Penalti Kemarin';

  static const String investClaim = 'Klaim';
  static const String investClaimDeviden = 'Klaim Dividen / Bunga';
  static const String investSellTitle = 'Penarikan Dana Investasi';
  static const String investTotalDeviden = 'Total Deviden';
  static const String investTotalDevidenRequired =
      'Total dividen tidak boleh kosong.';
  static const String investDevidenDesc =
      'Klaim dividen akan langsung ditambahkan sebagai saldo (Pemasukan) ke dompet pilihan Anda tanpa mengubah nilai buku investasi awal Anda.';
  static const String investInvalidUnitSell =
      'Unit yang dijual melebihi unit yang dimiliki.';
  static const String roundedCheck = 'Pembulatan Otomatis?';

  static const String historyInformation = 'Informasi Dasar';
  static const String breakdownDetail = 'Rincian Item';

  static const TermModel homeTotalBalance = TermModel(
    normal: 'Total Saldo',
    rpg: 'Total HP',
  );
  static const TermModel homePending = TermModel(
    normal: 'Alokasi Tertunda',
    rpg: 'Loot Belum Dibagi',
  );
  static const TermModel homeBreakdown = TermModel(
    normal: 'Rincian Alokasi',
    rpg: 'Rincian Distribusi',
  );
  static const TermModel homeRemainingToday = TermModel(
    normal: 'Sisa Hari Ini',
    rpg: 'Sisa Mana',
  );
  static const TermModel homeSavings = TermModel(
    normal: 'Tabungan',
    rpg: 'Cadangan',
  );
  static const TermModel homeRegular = TermModel(
    normal: 'Dana Utama',
    rpg: 'Reguler',
  );
  static const TermModel homeLimitOver = TermModel(
    normal: 'Melebihi Batas',
    rpg: 'Mana Habis',
  );

  static const TermModel walletCash = TermModel(
    normal: 'Tunai',
    rpg: 'Kantong Koin',
  );
  static const TermModel walletBank = TermModel(
    normal: 'Rekening Bank',
    rpg: 'Brankas Guild',
  );
  static const TermModel walletEwallet = TermModel(
    normal: 'Dompet Digital',
    rpg: 'Kantong Ajaib',
  );
  static const TermModel walletPlatform = TermModel(
    normal: 'Platform Bursa',
    rpg: 'Aula Saudagar',
  );
  static const TermModel walletDetail = TermModel(
    normal: 'Detail Dompet',
    rpg: 'Detail Penyimpanan',
  );
  static const TermModel addWallet = TermModel(
    normal: 'Tambah Dompet',
    rpg: 'Tambah Penyimpanan',
  );
  static const TermModel updateWallet = TermModel(
    normal: 'Perbarui Dompet',
    rpg: 'Perbarui Penyimpanan',
  );

  static const TermModel billsActive = TermModel(
    normal: 'Tenggat',
    rpg: 'Quest',
  );
  static const TermModel billsMaster = TermModel(
    normal: 'Tagihan',
    rpg: 'Master Quest',
  );
  static const TermModel debtsMaster = TermModel(
    normal: 'Hutang',
    rpg: 'Boss Raid',
  );
  static const TermModel billName = TermModel(
    normal: 'Nama Tagihan',
    rpg: 'Nama Quest',
  );
  static const TermModel billType = TermModel(
    normal: 'Siklus Penagihan',
    rpg: 'Tipe Quest',
  );
  static const TermModel billTypes = TermModel(
    normal: 'Tipe Tagihan',
    rpg: 'Jenis Quest',
  );
  static const TermModel billDay = TermModel(
    normal: 'Hari Penagihan',
    rpg: 'Hari Quest',
  );
  static const TermModel billDate = TermModel(
    normal: 'Tanggal Penagihan',
    rpg: 'Tanggal Quest',
  );
  static const TermModel billMonth = TermModel(
    normal: 'Bulan Penagihan',
    rpg: 'Bulan Quest',
  );
  static const TermModel billAmount = TermModel(
    normal: 'Nominal Tagihan',
    rpg: 'Nominal Quest',
  );
  static const TermModel billWarning = TermModel(
    normal: 'Tagihan ini sedang dinonaktifkan.',
    rpg: 'Quest ini sedang dinonaktifkan.',
  );
  static const TermModel billRequired = TermModel(
    normal: 'Silakan pilih tagihan.',
    rpg: 'Silakan pilih quest.',
  );
  static const TermModel nextBill = TermModel(
    normal: 'Jatuh Tempo Berikutnya',
    rpg: 'Quest Berikutnya',
  );

  static const TermModel debtName = TermModel(
    normal: 'Nama Pinjaman',
    rpg: 'Nama Boss',
  );
  static const TermModel debtAmount = TermModel(
    normal: 'Total Pinjaman',
    rpg: 'Total HP Boss',
  );
  static const TermModel debtRemaining = TermModel(
    normal: 'Sisa Pinjaman',
    rpg: 'Sisa HP Boss',
  );
  static const TermModel debtPayAmount = TermModel(
    normal: 'Sudah Dibayar',
    rpg: 'Total Damage',
  );
  static const TermModel debtType = TermModel(
    normal: 'Tipe Pinjaman',
    rpg: 'Tipe Boss',
  );
  static const TermModel debtAmountRequired = TermModel(
    normal: 'Total pinjaman tidak boleh kosong.',
    rpg: 'HP boss tidak boleh kosong.',
  );
  static const TermModel debtBillCheck = TermModel(
    normal: 'Buat Tagihan Rutin?',
    rpg: 'Buat Quest Rutin?',
  );
  static const TermModel debtBill = TermModel(
    normal: 'Tagihan Rutin',
    rpg: 'Quest Rutin',
  );
  static const TermModel debtBillAmount = TermModel(
    normal: 'Nominal Cicilan',
    rpg: 'Jumlah Demage',
  );

  static const TermModel debtRequired = TermModel(
    normal: 'Silakan pilih hutang.',
    rpg: 'Silakan pilih boss.',
  );

  static const TermModel debtEmpty = TermModel(
    normal: 'Anda tidak memiliki catatan hutang.',
    rpg: 'Tidak ada boss raid terdeteksi.',
  );

  static const TermModel generatBill = TermModel(
    normal: 'Generate Tagihan (Draf)',
    rpg: 'Aktifkan Quest (Draf)',
  );

  static const TermModel investModal = TermModel(
    normal: 'Modal Diinvestasikan',
    rpg: 'Gold Dikerahkan',
  );
  static const TermModel investTotal = TermModel(
    normal: 'Total Portofolio',
    rpg: 'Total Kekuatan Pasukan',
  );
  static const TermModel investValue = TermModel(
    normal: 'Nilai Saat Ini',
    rpg: 'Power Saat Ini',
  );
  static const TermModel investSell = TermModel(normal: 'Jual', rpg: 'Tarik');
  static const TermModel investAssetName = TermModel(
    normal: 'Aset',
    rpg: 'Pasukan',
  );
  static const TermModel investNewAsset = TermModel(
    normal: 'Aset Baru',
    rpg: 'Pasukan Baru',
  );
  static const TermModel investBuyAsset = TermModel(
    normal: 'Beli Aset',
    rpg: 'Sewa Pasukan',
  );
  static const TermModel investAddModal = TermModel(
    normal: 'Tambah Modal',
    rpg: 'Tambah Power',
  );
  static const TermModel investUpdatePrice = TermModel(
    normal: 'Perbarui Harga Pasar',
    rpg: 'Perbarui Power Pasukan',
  );
  static const TermModel investSellAsset = TermModel(
    normal: 'Tarik Modal / Jual',
    rpg: 'Tarik / Bubarkan Pasukan',
  );
  static const TermModel investUpdateAsset = TermModel(
    normal: 'Perbarui Data Aset',
    rpg: 'Perbarui Data Pasukan',
  );
  static const TermModel investAsset = TermModel(
    normal: 'Pilih Aset',
    rpg: 'Pilih Pasukan',
  );
  static const TermModel investUnit = TermModel(normal: 'Satuan', rpg: 'Unit');
  static const TermModel investRisk = TermModel(
    normal: 'Tingkat Risiko',
    rpg: 'Jenis Pasukan',
  );
  static const TermModel investAssetRequired = TermModel(
    normal: 'Silakan pilih aset.',
    rpg: 'Silakan pilih pasukan.',
  );
  static const TermModel investUnitRequired = TermModel(
    normal: 'Satuan',
    rpg: 'Unit',
  );
  static const TermModel investRiskRequired = TermModel(
    normal: 'Silakan pilih tingkat risiko.',
    rpg: 'Silakan pilih jenis pasukan.',
  );

  static const TermModel historyTransaction = TermModel(
    normal: 'Transaksi',
    rpg: 'Petualangan',
  );
  static const TermModel historyTime = TermModel(
    normal: 'Waktu Transaksi',
    rpg: 'Waktu Petualangan',
  );
  static const TermModel breakdownExpense = TermModel(
    normal: 'Rincian Pengeluaran',
    rpg: 'Analisis Damage',
  );
  static const TermModel breakdownInvest = TermModel(
    normal: 'Rincian Investasi',
    rpg: 'Analisis Armory',
  );
  static const TermModel recordExpense = TermModel(
    normal: 'Catat Pengeluaran',
    rpg: 'Catat Petualangan',
  );
  static const TermModel recordIncome = TermModel(
    normal: 'Catat Pemasukan',
    rpg: 'Catat Loot',
  );

  static const TermModel newTranfer = TermModel(
    normal: 'Tranfer Uang',
    rpg: 'Distribusi Mana',
  );
  static const TermModel saveExpense = TermModel(
    normal: 'Simpan Pengeluaran',
    rpg: 'Simpan Petualangan',
  );
  static const TermModel saveIncome = TermModel(
    normal: 'Simpan Pemasukan',
    rpg: 'Simpan Loot',
  );
  static const TermModel expenseAmount = TermModel(
    normal: 'Total Pembayaran',
    rpg: 'Total Penggunaan',
  );

  static const IconModel addIcon = IconModel(
    normal: FontAwesomeIcons.receipt,
    rpg: FontAwesomeIcons.dragon,
  );

  static const IconModel investAdd = IconModel(
    normal: FontAwesomeIcons.folderPlus,
    rpg: FontAwesomeIcons.flag,
  );

  static const CategoryModel homeDailyLimit = CategoryModel(
    terminology: TermModel(normal: 'Batas Harian', rpg: 'Limit Mana'),
    icons: IconModel(
      normal: FontAwesomeIcons.bolt,
      rpg: FontAwesomeIcons.flask,
    ),
  );

  static const CategoryModel addBill = CategoryModel(
    terminology: TermModel(
      normal: 'Tambah Tagihan Baru',
      rpg: 'Tambah Master Quest',
    ),
    description: 'Buat tagihan pembayaran rutin baru',
    icons: IconModel(
      normal: FontAwesomeIcons.receipt,
      rpg: FontAwesomeIcons.scroll,
    ),
  );

  static const CategoryModel addDebt = CategoryModel(
    terminology: TermModel(normal: 'Tambah Hutang', rpg: 'Tambah Boss Raid'),
    description: 'Catat pinjaman atau hutang besar baru',
    icons: IconModel(
      normal: FontAwesomeIcons.buildingColumns,
      rpg: FontAwesomeIcons.dragon,
    ),
  );

  static const CategoryModel billsPayAction = CategoryModel(
    terminology: TermModel(normal: 'Bayar', rpg: 'Serang'),
    icons: IconModel(
      normal: FontAwesomeIcons.check,
      rpg: FontAwesomeIcons.wandMagicSparkles,
    ),
  );

  static String getHomeSpent(String spent, String limit) =>
      'Dihabiskan: $spent / $limit';

  static String getHomeLimitOver(String formattedOverage) =>
      'Offset Hari Ini: $formattedOverage';

  static String getHomeNote(String name, String amount, {bool isRpg = false}) {
    final tabungan = homeSavings.get(isRpg).toLowerCase();
    return 'Transaksi ini akan menggunakan dana $tabungan **$name**. Saldo $tabungan saat ini: **$amount**';
  }

  static String getReservedCheck({bool isRpg = false}) =>
      'Menggunakan ${homeSavings.get(isRpg)}?';

  static String getExcludeDailyCheck({bool isRpg = false}) =>
      'Kecualikan ${historyTransaction.get(isRpg)}?';

  static String getReservedCheckDesc({bool isRpg = false}) =>
      'Kurangi jumlah ini dari alokasi ${homeSavings.get(isRpg).toLowerCase()} Anda, bukan dari saldo aktif Anda.';

  static String getExcludeDailyCheckDesc({bool isRpg = false}) =>
      'Kurangi jumlah ini dari alokasi ${homeSavings.get(isRpg).toLowerCase()} Anda, bukan dari saldo aktif Anda.';

  static String getRoundedCheckDesc({bool isRpg = false}) =>
      'Membulatkan ${expenseAmount.get(isRpg).toLowerCase()} ke atas untuk menghilangkan fraksi desimal pada saldo akhir dompet.';

  static String getDebtBillTitle(String title) => 'Cicilan: $title';

  static String getDebtBillDesc({bool isRpg = false}) =>
      'Aktifkan untuk notifikasi atau ${billsMaster.get(isRpg)} otomatis generate setiap periode tertentu.';

  static String getPayBill({String? amount, bool isRpg = false}) {
    String result = isRpg ? 'Jalankan Quest' : 'Bayar Tagihan';
    if (amount != null) result += ' ($amount)';
    return result;
  }

  static String getPayDebt({bool isCustom = true, bool isRpg = false}) {
    String result = isRpg ? 'Serang Boss' : 'Bayar Sisa Pokok';
    if (isCustom) result += ' (Custom)';
    return result;
  }

  static String getBillTypes({required bool isBillDebt, bool isRpg = false}) {
    if (isBillDebt) {
      if (isRpg) {
        return 'Cicil HP Boss';
      } else {
        return 'Cicilan Tagihan';
      }
    } else {
      if (isRpg) {
        return 'Quest Rutin';
      } else {
        return 'Tagihan Rutin';
      }
    }
  }

  static String getInvestDevidenPerUnit(String unitName) =>
      'Dividen per $unitName';

  static String getInvestPricePerUnit(String unitName) =>
      'Harga Beli per $unitName';

  static String getClaimTitle({
    required String name,
    required String unit,
    required String unitName,
  }) => 'Aset: $name ($unit $unitName)';

  static String getInvestUpdateDesc({bool isRpg = false}) =>
      'Memperbarui ${isRpg ? 'power pasukan' : 'total harga pasar '} tidak akan mengubah catatan modal awal yang sudah Anda keluarkan. Ini murni untuk memantau ${isRpg ? 'nilai aset' : 'power pasukan'}  Anda saat ini.';

  static String getInvestNote(String name, String amount) =>
      'Sisa saldo **$name** yang belum dialokasikan adalah **$amount**. Pembelian investasi ini akan memotong saldo tersebut.';

  static String getEmergencyCheck({bool isRpg = false}) =>
      'Sebagai ${GamificationDict.skillEmergency.get(isRpg)}?';

  static String getEmergencyCheckDesc({bool isRpg = false}) =>
      'Aktifkan jika ${investAssetName.get(isRpg).toLowerCase()} ini disiapkan sebagai ${GamificationDict.skillEmergency.get(isRpg).toLowerCase()}.';

  static String getDevidenCheck({bool isRpg = false}) =>
      '${investAssetName.get(isRpg)} Menghasilkan Dividen/Bunga?';

  static String getDevidenCheckDesc({bool isRpg = false}) =>
      'Aktifkan jika ${investAssetName.get(isRpg).toLowerCase()} ini memberikan imbal hasil rutin (seperti dividen saham atau kupon obligasi) yang nantinya dapat Anda klaim ke dompet.';

  static String getBillPay(String amount, {bool isRpg = false}) =>
      '${isRpg ? 'Damage' : 'Dibayar'} $amount';

  static String getBillLockCheck({bool isRpg = false}) =>
      'Nonaktifkan ${billsMaster.get(isRpg)}?';

  static String getBillLockCheckDesc({bool isRpg = false}) =>
      'Aktifkan jika ${billsMaster.get(isRpg).toLowerCase()} ini sudah tidak dibutuhkan. Sistem notifikasi dan pembayaran akan dinonaktifkan hingga anda  mengaktifkanya lagi di kemudian hari.';

  static String getBillNotif({bool isSuccess = false, bool isRpg = false}) {
    if (isRpg) {
      return 'Quest ${isSuccess ? 'berhasil' : 'gagal'} dijalankan.';
    } else {
      return 'Tagihan ${isSuccess ? 'berhasil' : 'gagal'} dibayar.';
    }
  }

  static String getDebtNotif({bool isSuccess = false, bool isRpg = false}) {
    if (isRpg) {
      return 'Boss Raid ${isSuccess ? 'berhasil' : 'gagal'} diserang.';
    } else {
      return 'Pembayaran hutang ${isSuccess ? 'berhasil' : 'gagal'} dicatat.';
    }
  }

  static String getInvestModalNotif({
    bool isSuccess = false,
    bool isRpg = false,
  }) {
    return '${isRpg ? 'Power' : 'Modal'} ${isSuccess ? 'berhasil' : 'gagal'} ditambah.';
  }

  static String getInvestSellNotif({
    bool isSuccess = false,
    bool isRpg = false,
  }) {
    return '${investAssetName.get(isRpg)} ${isSuccess ? 'berhasil' : 'gagal'} ditarik.';
  }

  static String getFeeCheckDesc({bool isIncome = false, bool isRpg = false}) =>
      'Jika biaya tersebut aktif, nominal ${isIncome ? UiDict.income.get(isRpg).toLowerCase() : UiDict.expense.get(isRpg).toLowerCase()} akan ${isIncome ? 'dikurangi' : 'ditambah'} biaya tersebut${isIncome ? ' sebelum ditambahkan ke dompet Anda' : ''}.';

  static String getHistoryNote(String name, String amount) =>
      'Saldo dompet **$name** saat ini: **$amount**';
}
