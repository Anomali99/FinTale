import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TermPair {
  final String normal;
  final String rpg;

  const TermPair({required this.normal, required this.rpg});

  String get(bool isRpgMode) => isRpgMode ? rpg : normal;
}

class IconPair {
  final FaIconData normal;
  final FaIconData rpg;

  const IconPair({required this.normal, required this.rpg});

  FaIconData get(bool isRpgMode) => isRpgMode ? rpg : normal;
}

class AppDictionary {
  static const TermPair totalBalance = TermPair(
    normal: 'Total Balance',
    rpg: 'Total HP',
  );
  static const TermPair walletDetails = TermPair(
    normal: 'Wallet Details',
    rpg: 'Inventory Details',
  );
  static const TermPair income = TermPair(normal: 'Income', rpg: 'Loot');
  static const TermPair transfer = TermPair(
    normal: 'Transfer',
    rpg: 'Distribute',
  );
  static const TermPair upcomingBills = TermPair(
    normal: 'Upcoming Bills',
    rpg: 'Active Threats',
  );
  static const TermPair dailyLimit = TermPair(
    normal: 'Daily Limit',
    rpg: 'Daily Mana',
  );
  static const TermPair remainingToday = TermPair(
    normal: 'Remaining Today',
    rpg: 'Remaining Mana',
  );
  static const TermPair home = TermPair(normal: 'Home', rpg: 'Guild Hall');
  static const TermPair bills = TermPair(normal: 'Bills', rpg: 'Quest Board');
  static const TermPair invest = TermPair(normal: 'Invest', rpg: 'Armory');
  static const TermPair history = TermPair(
    normal: 'History',
    rpg: 'Battle Log',
  );
  static const TermPair pay = TermPair(
    normal: 'Pay Debt',
    rpg: 'Attack Attack Boss',
  );
  static const TermPair payDec = TermPair(
    normal: 'Record a debt installment',
    rpg: 'Record a boss battle (debt payment)',
  );
  static const TermPair daily = TermPair(
    normal: 'Daily Expense',
    rpg: 'Use Mana',
  );
  static const TermPair dailyDec = TermPair(
    normal: 'Record food, transport, etc.',
    rpg: 'Record a daily expenditure',
  );
  static const TermPair cash = TermPair(normal: 'Cash', rpg: 'Gold Pouch');
  static const TermPair bankAccount = TermPair(
    normal: 'Bank Account',
    rpg: 'Vault',
  );
  static const TermPair eWallet = TermPair(
    normal: 'E-Wallet',
    rpg: 'Magic Satchel',
  );
  static const TermPair noviceSaver = TermPair(
    normal: 'Novice Saver',
    rpg: 'Novice Adventurer',
  );
  static const TermPair smartBudgeter = TermPair(
    normal: 'Smart Budgeter',
    rpg: 'Elite Ranger',
  );
  static const TermPair wiseInvestor = TermPair(
    normal: 'Wise Investor',
    rpg: 'Valiant Knight',
  );
  static const TermPair wealthBuilder = TermPair(
    normal: 'Wealth Builder',
    rpg: 'Grand Champion',
  );
  static const TermPair financialMaster = TermPair(
    normal: 'Financial Master',
    rpg: 'Guild Legend',
  );
  static const TermPair allocationRules = TermPair(
    normal: 'Allocation Rules',
    rpg: 'Guild Strategy',
  );

  static const TermPair appSettings = TermPair(
    normal: 'App Settings',
    rpg: 'World Settings',
  );

  static const TermPair notifDec = TermPair(
    normal: 'Bill & Target reminders',
    rpg: 'Quest & Threat alerts',
  );

  static const IconPair incomeIcon = IconPair(
    normal: FontAwesomeIcons.arrowTurnDown,
    rpg: FontAwesomeIcons.sackDollar,
  );
  static const IconPair transferIcon = IconPair(
    normal: FontAwesomeIcons.moneyBillTransfer,
    rpg: FontAwesomeIcons.dolly,
  );
  static const IconPair payIcon = IconPair(
    normal: FontAwesomeIcons.buildingColumns,
    rpg: FontAwesomeIcons.khanda,
  );
  static const IconPair dailyIcon = IconPair(
    normal: FontAwesomeIcons.wallet,
    rpg: FontAwesomeIcons.flask,
  );
  static const IconPair homeIcon = IconPair(
    normal: FontAwesomeIcons.house,
    rpg: FontAwesomeIcons.chessRook,
  );
  static const IconPair billsIcon = IconPair(
    normal: FontAwesomeIcons.receipt,
    rpg: FontAwesomeIcons.scroll,
  );
  static const IconPair investIcon = IconPair(
    normal: FontAwesomeIcons.chartLine,
    rpg: FontAwesomeIcons.shieldHalved,
  );
  static const IconPair historyIcon = IconPair(
    normal: FontAwesomeIcons.clockRotateLeft,
    rpg: FontAwesomeIcons.bookJournalWhills,
  );
}
