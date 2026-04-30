import '../../models/allocation_model.dart';
import '../../models/user_allocation_model.dart';
import '../../models/user_budget_model.dart';
import '../../models/user_model.dart';
import '../../models/user_progress_model.dart';
import '../../models/wallet_model.dart';

class StarterPack {
  static UserModel generateUser({
    required String uid,
    required String name,
    String? email,
  }) => UserModel(
    uid: uid,
    name: name.isEmpty ? 'Adventurer' : name,
    email: email,
    title: TitleType.noviceSaver,
    level: 1,
    xp: 0,
    budget: UserBudgetModel(
      lastActiveDate: DateTime.now().microsecondsSinceEpoch,
    ),
    allocation: UserAllocationModel(
      skills: {
        SectorType.living: 55.0,
        SectorType.payDebt: 25.0,
        SectorType.emergency: 20.0,
        SectorType.investment: null,
        SubSectorType.essentials: 55.0,
        SubSectorType.dreamFund: 0.0,
        SubSectorType.lowRisk: 20.0,
        SubSectorType.mediumRisk: null,
        SubSectorType.highRisk: null,
      },
    ),
    progress: UserProgressModel(),
  );

  static WalletModel get defaultWallet =>
      WalletModel(name: 'Cash', type: WalletType.cash, amount: BigInt.zero);
}
