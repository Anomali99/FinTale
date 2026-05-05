import '../models/term_model.dart';

class HomeDict {
  static const String addWallet = 'Tembah Dompet';
  static const String updateWallet = 'Perbarui Dompet';
  static const String walletName = 'Nama Dompet';
  static const String walletType = 'Jenis Dompet';
  static const String initialAmount = 'Jumlah Awal';
  static const String newTransfer = 'Transfer Uang';
  static const String recordIncome = 'Catat Pemasukan';
  static const String addIncome = 'Tambah Pemasukan';
  static const String feeAmount = 'Biaya Admin';
  static const String feeCheck = 'Apakah ada biaya administrasi?';
  static const String requiredFee = 'Biaya admin tidak boleh kosong.';
  static const String feeCheckDesc =
      'Centang ini jika penghasilan tersebut dikenakan biaya potongan.';
  static const String feeDesc =
      'Jika biaya tersebut aktif, jumlah pendapatan akan dikurangi biaya tersebut sebelum ditambahkan ke dompet Anda.';
  static const String reservedCheck = 'Menggunakan Dana Cadangan?';
  static const String reservedCheckDesc =
      'Kurangi jumlah ini dari alokasi cadangan Anda, bukan dari saldo aktif Anda.';
  static const String autoCheck = 'Alokasi Otomatis?';
  static const String autoCheckDesc =
      'Secara otomatis, distribusikan pendapatan ini ke sektor Anda berdasarkan skill Anda.';
  static const String breakdown = 'Rincian Alokasi';

  static const TermModel totalBalance = TermModel(
    normal: 'Total Saldo',
    rpg: 'Total HP',
  );

  static const TermModel walletDetails = TermModel(
    normal: 'Detail Dompet',
    rpg: 'Isi Tas (Inventory)',
  );

  static const TermModel dailyLimit = TermModel(
    normal: 'Batas Harian',
    rpg: 'Limit Mana',
  );

  static const TermModel remainingToday = TermModel(
    normal: 'Sisa Hari Ini',
    rpg: 'Sisa Mana',
  );

  static const TermModel cash = TermModel(normal: 'Tunai', rpg: 'Kantong Koin');

  static const TermModel bankAccount = TermModel(
    normal: 'Rekening Bank',
    rpg: 'Brankas Guild',
  );

  static const TermModel eWallet = TermModel(
    normal: 'Dompet Digital',
    rpg: 'Kantong Ajaib',
  );

  static const TermModel platform = TermModel(
    normal: 'Platform Bursa',
    rpg: 'Pasar Gelap',
  );

  static const TermModel savings = TermModel(
    normal: 'Tabungan',
    rpg: 'Cadangan',
  );

  static const TermModel pending = TermModel(
    normal: 'Alokasi Tertunda',
    rpg: 'Loot Belum Dibagi',
  );

  static String generateNote(String name, String amount) =>
      'Transaksi ini akan menggunakan dana cadangan **$name**. Saldo cadangan saat ini: **$amount**';
}
