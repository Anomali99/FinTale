import '../../models/user_allocation_model.dart';
import '../../models/user_budget_model.dart';
import '../../models/user_model.dart';
import '../../models/user_progress_model.dart';
import '../../models/wallet_model.dart';
import 'leveling_extension.dart';

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
      lastActiveDate: DateTime.now().millisecondsSinceEpoch,
      isFreeDebt: true,
    ),
    allocation: UserAllocationModel(
      skills: AllocationMap.getAllocationByLevel(1, noDebt: true),
    ),
    progress: UserProgressModel(),
  );

  static WalletModel get defaultWallet =>
      WalletModel(name: 'Cash', type: WalletType.cash, amount: BigInt.zero);
}
