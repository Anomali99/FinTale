import 'package:decimal/decimal.dart';

import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import 'enum_types.dart';
import 'leveling_extension.dart';

class StarterPack {
  static UserModel generateUser({
    required String uid,
    String? name,
    String? email,
  }) => UserModel(
    uid: uid,
    name: name ?? 'Adventurer',
    email: email,
    title: TitleType.noviceSaver,
    level: 1,
    xp: 0,
    budget: UserBudgetModel(lastActiveDate: 0, isFreeDebt: true),
    allocation: UserAllocationModel(
      skills: AllocationMap.getAllocationByLevel(1, noDebt: true),
    ),
    progress: UserProgressModel(),
  );

  static WalletModel get defaultWallet =>
      WalletModel(name: 'Cash', type: WalletType.cash, amount: Decimal.zero);
}
