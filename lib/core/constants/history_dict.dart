import '../models/term_model.dart';

class HistoryDict {
  static const TermModel cashFlow = TermModel(
    normal: 'Cash Flow',
    rpg: 'Mana Flow',
  );

  static const TermModel macroOverview = TermModel(
    normal: 'Cash Flow Overview',
    rpg: 'Trinity of Mana',
  );

  static const TermModel breakdownExpense = TermModel(
    normal: 'Expense Breakdown',
    rpg: 'Damage Analysis',
  );

  static const TermModel breakdownInvest = TermModel(
    normal: 'Investment Breakdown',
    rpg: 'Armory Analysis',
  );

  static const TermModel topExpenses = TermModel(
    normal: 'Top Expenses',
    rpg: 'Major Threats',
  );
}
