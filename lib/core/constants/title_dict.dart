import '../../models/user_model.dart';
import '../models/term_model.dart';

class TitleDict {
  static const TermModel noviceSaver = TermModel(
    normal: 'Novice Saver',
    rpg: 'Novice Adventurer',
  );

  static const TermModel smartBudgeter = TermModel(
    normal: 'Smart Budgeter',
    rpg: 'Elite Ranger',
  );

  static const TermModel wiseInvestor = TermModel(
    normal: 'Wise Investor',
    rpg: 'Valiant Knight',
  );

  static const TermModel wealthBuilder = TermModel(
    normal: 'Wealth Builder',
    rpg: 'Grand Champion',
  );

  static const TermModel financialMaster = TermModel(
    normal: 'Financial Master',
    rpg: 'Guild Legend',
  );

  static TermModel getByEnum(TitleType title) {
    switch (title) {
      case TitleType.noviceSaver:
        return noviceSaver;
      case TitleType.smartBudgeter:
        return smartBudgeter;
      case TitleType.wiseInvestor:
        return wiseInvestor;
      case TitleType.wealthBuilder:
        return wealthBuilder;
      case TitleType.financialMaster:
        return financialMaster;
    }
  }
}
