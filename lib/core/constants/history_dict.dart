import '../models/term_model.dart';

class HistoryDict {
  static const TermModel cashFlow = TermModel(
    normal: 'Arus Kas',
    rpg: 'Aliran Mana',
  );

  static const TermModel macroOverview = TermModel(
    normal: 'Ringkasan Arus Kas',
    rpg: 'Trinitas Mana',
  );

  static const TermModel breakdownExpense = TermModel(
    normal: 'Rincian Pengeluaran',
    rpg: 'Analisis Damage',
  );

  static const TermModel breakdownInvest = TermModel(
    normal: 'Rincian Investasi',
    rpg: 'Analisis Armory',
  );

  static const TermModel topExpenses = TermModel(
    normal: 'Pengeluaran Terbesar',
    rpg: 'Ancaman Utama',
  );
}
