import '../models/term_model.dart';

class HistoryDict {
  static const String status = 'Status';
  static const String information = 'Informasi Dasar';
  static const String detailBreakdown = 'Rincian Item';
  static const String emptyAnalytics = 'Belum Ada Data';
  static const String saveTo = 'Disimpan ke';
  static const String originWallet = 'Dompet Asal';
  static const String destinationWallet = 'Dompet Tujuan';
  static const String sourceFunds = 'Sumber Dana';
  static const String expenseAmount = 'Total Pembayaran';
  static const String addItem = 'Tambah Item Lagi';
  static const String deleteItem = 'Hapus Item';
  static const String price = 'Harga';
  static const String resetTime = 'Reset ke waktu sekarang';

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

  static const TermModel recordExpense = TermModel(
    normal: 'Catat Pengeluaran',
    rpg: 'Catat Petualangan',
  );

  static const TermModel saveExpense = TermModel(
    normal: 'Simpan Pengeluaran',
    rpg: 'Simpan Petualangan',
  );

  static String generateNote(String name, String amount) =>
      'Saldo dompet **$name** saat ini: **$amount**';
}
