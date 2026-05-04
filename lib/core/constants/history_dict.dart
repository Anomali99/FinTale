import '../models/term_model.dart';

class HistoryDict {
  static const String status = 'Status';
  static const String detailBreakdown = 'Rincian Item';
  static const String emptyAnalytics = 'Belum Ada Data';
  static const String saveTo = 'Disimpan ke';
  static const String originWallet = 'Origin Wallet';
  static const String destinationWallet = 'Dompet Tujuan';

  static const TermModel breakdownExpense = TermModel(
    normal: 'Rincian Pengeluaran',
    rpg: 'Analisis Damage',
  );

  static const TermModel breakdownInvest = TermModel(
    normal: 'Rincian Investasi',
    rpg: 'Analisis Armory',
  );

  static const TermModel empty = TermModel(
    normal: 'Belum Ada Transaksi',
    rpg: 'Belum Ada Catatan',
  );

  static const TermModel adventureTime = TermModel(
    normal: 'Waktu Transaksi',
    rpg: 'Waktu Petualangan',
  );
}
