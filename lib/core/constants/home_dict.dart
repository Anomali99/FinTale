import '../models/term_model.dart';

class HomeDict {
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
}
