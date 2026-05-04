import 'package:decimal/decimal.dart';

import '../../models/assets_model.dart';
import '../../models/bill_model.dart';
import '../../models/debt_model.dart';
import '../../models/transaction_detail_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import '../utils/starter_pack.dart';

class DummyData {
  static UserModel user = StarterPack.generateUser(
    uid: "12345",
    name: "Anomali99",
  );

  static List<WalletModel> wallets = [
    WalletModel(
      id: 1,
      name: "Cash",
      type: WalletType.cash,
      amount: BigInt.from(150000),
    ),
    WalletModel(
      id: 2,
      name: "Bank BCA",
      type: WalletType.bank,
      amount: BigInt.from(5500000),
    ),
    WalletModel(
      id: 3,
      name: "GoPay",
      type: WalletType.eWallet,
      amount: BigInt.from(250000),
    ),
    WalletModel(
      id: 4,
      name: "Ajaib",
      type: WalletType.platform,
      amount: BigInt.from(50000),
    ),
  ];

  static List<AssetsModel> assets = [
    AssetsModel(
      id: 1,
      name: "Saham BBCA",
      type: RiskType.medium,
      category: AssetsCategory.stocks,
      unitName: "Lot",
      invested: BigInt.from(10000000),
      value: BigInt.from(11500000),
      unit: Decimal.parse('10'),
      hasDividend: true,
    ),
    AssetsModel(
      id: 2,
      name: "Bitcoin (BTC)",
      type: RiskType.high,
      category: AssetsCategory.crypto,
      unitName: "BTC",
      invested: BigInt.from(5000000),
      value: BigInt.from(4800000),
      unit: Decimal.parse('0.00451234'),
    ),
  ];

  static List<BillModel> bills = [listrikBill, kprBill, wifiBill];

  static List<DebtModel> debts = [
    DebtModel(
      id: 1,
      title: "KPR Kastil Utama",
      amount: BigInt.from(300000000),
      type: DebtType.mortgage,
      bill: kprBill,
      paidAmount: BigInt.from(15000000),
    ),
  ];

  static List<TransactionModel> transactions = [
    TransactionModel(
      id: 1,
      walletId: 2,
      title: "Gaji Guild Master",
      amount: BigInt.from(8000000),
      status: StatusType.paid,
      type: TransactionType.income,
      dateTimestamp: DateTime.now()
          .subtract(const Duration(days: 5))
          .millisecondsSinceEpoch,
      detailTransaction: [
        TransactionDetailModel(
          title: "Bounty Bulanan",
          amount: BigInt.from(8000000),
          category: TransactionCategory.salary,
          flow: FlowType.income,
        ),
      ],
    ),

    TransactionModel(
      id: 2,
      walletId: 3,
      title: "Belanja Indomaret",
      amount: BigInt.from(65000),
      status: StatusType.paid,
      type: TransactionType.expense,
      dateTimestamp: DateTime.now()
          .subtract(const Duration(days: 2))
          .millisecondsSinceEpoch,
      detailTransaction: [
        TransactionDetailModel(
          title: "Beli Potion (Kopi)",
          amount: BigInt.from(25000),
          category: TransactionCategory.food,
          flow: FlowType.expense,
        ),
        TransactionDetailModel(
          title: "Sabun & Tisu",
          amount: BigInt.from(40000),
          category: TransactionCategory.groceries,
          flow: FlowType.expense,
        ),
      ],
    ),

    TransactionModel(
      id: 3,
      walletId: 4,
      assetsId: 1,
      title: "Dividen Saham BBCA",
      amount: BigInt.from(250000),
      status: StatusType.paid,
      type: TransactionType.income,
      dateTimestamp: DateTime.now()
          .subtract(const Duration(days: 1))
          .millisecondsSinceEpoch,
      detailTransaction: [
        TransactionDetailModel(
          title: "Passive Loot BBCA",
          amount: BigInt.from(250000),
          category: TransactionCategory.dividend,
          flow: FlowType.income,
        ),
      ],
    ),

    TransactionModel(
      id: 4,
      walletId: 4,
      assetsId: 2,
      title: "Beli Bitcoin dari Dividen",
      amount: BigInt.from(200000),
      status: StatusType.paid,
      type: TransactionType.expense,
      dateTimestamp: DateTime.now().millisecondsSinceEpoch,
      detailTransaction: [
        TransactionDetailModel(
          title: "Tambah Pasukan Kripto",
          amount: BigInt.from(200000),
          category: TransactionCategory.lowRisk,
          flow: FlowType.expense,
        ),
      ],
    ),

    TransactionModel(
      id: 5,
      billId: 1,
      title: "Token Listrik Markas",
      amount: BigInt.from(250000),
      status: StatusType.pending,
      type: TransactionType.expense,
      dateTimestamp: DateTime.now().millisecondsSinceEpoch,
      detailTransaction: [
        TransactionDetailModel(
          title: "Bill April 2026",
          amount: BigInt.from(250000),
          category: TransactionCategory.utilities,
          flow: FlowType.expense,
        ),
      ],
    ),

    TransactionModel(
      id: 6,
      billId: 2,
      title: "Cicilan KPR Kastil",
      amount: BigInt.from(1500000),
      status: StatusType.overdue,
      type: TransactionType.expense,
      dateTimestamp: DateTime.now().millisecondsSinceEpoch,
      detailTransaction: [
        TransactionDetailModel(
          title: "Bill April 2026",
          amount: BigInt.from(1500000),
          category: TransactionCategory.debtInstallment,
          flow: FlowType.expense,
        ),
      ],
    ),

    TransactionModel(
      id: 7,
      billId: 3,
      title: "Kuota Wifi",
      amount: BigInt.from(100000),
      status: StatusType.paid,
      type: TransactionType.expense,
      dateTimestamp: DateTime.now().millisecondsSinceEpoch,
      detailTransaction: [
        TransactionDetailModel(
          title: "Bill April 2026",
          amount: BigInt.from(100000),
          category: TransactionCategory.utilities,
          flow: FlowType.expense,
        ),
      ],
    ),
  ];

  static final BillModel listrikBill = BillModel(
    id: 1,
    title: "Token Listrik Markas",
    amount: BigInt.from(250000),
    type: TimeType.monthly,
    day: 20,
  );

  static final BillModel kprBill = BillModel(
    id: 2,
    debtId: 1,
    title: "Cicilan KPR Kastil",
    amount: BigInt.from(1500000),
    type: TimeType.monthly,
    day: 1,
  );

  static final BillModel wifiBill = BillModel(
    id: 3,
    title: "Kuota Wifi",
    amount: BigInt.from(100000),
    type: TimeType.monthly,
    day: 1,
  );
}
