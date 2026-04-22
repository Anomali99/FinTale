import '../models/term_model.dart';

class HomeDict {
  static const TermModel totalBalance = TermModel(
    normal: 'Total Balance',
    rpg: 'Total HP',
  );

  static const TermModel walletDetails = TermModel(
    normal: 'Wallet Details',
    rpg: 'Inventory Details',
  );

  static const TermModel upcomingBills = TermModel(
    normal: 'Upcoming Bills',
    rpg: 'Active Threats',
  );

  static const TermModel dailyLimit = TermModel(
    normal: 'Daily Limit',
    rpg: 'Daily Mana',
  );

  static const TermModel remainingToday = TermModel(
    normal: 'Remaining Today',
    rpg: 'Remaining Mana',
  );

  static const TermModel cash = TermModel(normal: 'Cash', rpg: 'Gold Pouch');
  static const TermModel bankAccount = TermModel(
    normal: 'Bank Account',
    rpg: 'Vault',
  );

  static const TermModel eWallet = TermModel(
    normal: 'E-Wallet',
    rpg: 'Magic Satchel',
  );

  static const TermModel platform = TermModel(
    normal: 'Platform / RDN',
    rpg: 'Trade Post',
  );
}
