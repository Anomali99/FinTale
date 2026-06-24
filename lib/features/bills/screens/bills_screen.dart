import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/analytics_controller.dart';
import '../../../controllers/bill_controller.dart';
import '../../../controllers/history_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/global_messenger.dart';
import '../../../models/bill_model.dart';
import '../../../models/debt_model.dart';
import '../../../models/transaction_model.dart';
import '../../../widgets/custom_bottom_sheet.dart';
import '../widgets/active_bills_tab.dart';
import '../widgets/add_bill_modal.dart';
import '../widgets/add_debt_modal.dart';
import '../widgets/bill_detail_modal.dart';
import '../widgets/bills_tab.dart';
import '../widgets/debt_detail_modal.dart';
import '../widgets/debts_tab.dart';
import '../widgets/pay_bill_modal.dart';
import '../widgets/pay_debt_modal.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  void _openDebtDetail(BuildContext context, DebtModel data, bool isRpg) async {
    final result = await showModalBottomSheet<DebtActionType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DebtDetailModal(debt: data, isRpg: isRpg),
    );

    if (result != null && context.mounted) {
      if (result == DebtActionType.payDirect) {
        _openPayDebtOrBillModal(
          context,
          initialDebt: data,
          title: ScreenDict.getPayBill(isRpg: isRpg),
        );
      } else if (result == DebtActionType.payBill) {
        _openPayDebtOrBillModal(
          context,
          initialBill: data.bill,
          title: ScreenDict.getPayDebt(isCustom: false, isRpg: isRpg),
        );
      } else if (result == DebtActionType.edit) {
        _openAddDebtModal(context, initialDebt: data);
      }
    }
  }

  void _openBillDetail(BuildContext context, BillModel data, bool isRpg) async {
    final result = await showModalBottomSheet<BillActionType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BillDetailModal(bill: data, isRpg: isRpg),
    );

    if (result != null && context.mounted) {
      if (result == BillActionType.payDirect) {
        _openPayDebtOrBillModal(
          context,
          initialBill: data,
          title: ScreenDict.getPayBill(isRpg: isRpg),
        );
      } else if (result == BillActionType.generateDraft) {
        bool isSuccess = await context.read<BillController>().generateBillDraft(
          data,
        );
        GlobalMessenger.showMessage(
          message: isSuccess
              ? UiDict.successGenerateDraft
              : UiDict.failedGenerateDraft,
          isSuccess: isSuccess,
        );
      } else if (result == BillActionType.edit) {
        _openAddBillModal(context, initialBill: data);
      }
    }
  }

  void _openAddBillModal(BuildContext context, {BillModel? initialBill}) async {
    final isRpg = context.read<SettingsController>().isRpgMode;
    final result = await showModalBottomSheet<BillModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddBillModal(initialBill: initialBill);
      },
    );

    if (result != null && context.mounted) {
      bool isSuccess = await context.read<BillController>().createBill(result);
      GlobalMessenger.showMessage(
        message: UiDict.getSaveNotif(
          ScreenDict.billsMaster.get(isRpg),
          isSuccess: isSuccess,
          isUpdate: initialBill != null,
        ),
        isSuccess: isSuccess,
      );
    }
  }

  void _openAddDebtModal(BuildContext context, {DebtModel? initialDebt}) async {
    final isRpg = context.read<SettingsController>().isRpgMode;
    final result = await showModalBottomSheet<DebtModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddDebtModal(initialDebt: initialDebt);
      },
    );

    if (result != null && context.mounted) {
      bool isSuccess = await context.read<BillController>().createDebt(result);
      GlobalMessenger.showMessage(
        message: UiDict.getSaveNotif(
          ScreenDict.debtsMaster.get(isRpg),
          isSuccess: isSuccess,
          isUpdate: initialDebt != null,
        ),
        isSuccess: isSuccess,
      );
    }
  }

  void _openPayDebtOrBillModal(
    BuildContext context, {
    required String title,
    DebtModel? initialDebt,
    BillModel? initialBill,
  }) async {
    final billController = context.read<BillController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final isRpg = context.read<SettingsController>().isRpgMode;
    final wallets = context.read<WalletController>().wallets;
    List<DebtModel> debts = initialDebt != null ? [initialDebt] : [];
    List<BillModel> bills = initialBill != null ? [initialBill] : [];
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PayDebtModal(
          title: title,
          wallets: wallets,
          debts: debts,
          bils: bills,
        );
      },
    );

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      bool useReserved = result['use_reserved'];
      bool isBill = result['is_bill'];
      bool isSuccess = false;
      String message = '';
      if (isBill) {
        isSuccess = await billController.payBill(
          transaction,
          useReserved: useReserved,
        );
        message = ScreenDict.getBillNotif(isSuccess: isSuccess, isRpg: isRpg);
      } else {
        isSuccess = await billController.payDebt(
          transaction,
          useReserved: useReserved,
        );
        message = ScreenDict.getDebtNotif(isSuccess: isSuccess, isRpg: isRpg);
      }
      await historyController.applyFilter();
      await analyticsController.applyFilter();
      GlobalMessenger.showMessage(message: message, isSuccess: isSuccess);
    }
  }

  void _openActiveBillModal(BuildContext context, TransactionModel data) async {
    final billController = context.read<BillController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PayBillModal(transaction: data);
      },
    );

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      bool useReserved = result['use_reserved'];
      await billController.payBill(
        transaction,
        useReserved: useReserved,
        checkExisting: false,
      );
      await historyController.applyFilter();
      await analyticsController.applyFilter();
    }
  }

  void _showActionPopup(BuildContext context, bool isRpg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (con) {
        return CustomBottomSheet(
          children: [
            BottomSheetChild(
              title: ScreenDict.addBill.get(isRpg),
              subtitle: ScreenDict.addBill.description ?? "",
              color: Colors.blueAccent,
              icon: ScreenDict.addBill.icon(isRpg),
              onTap: () {
                Navigator.pop(con);
                _openAddBillModal(context);
              },
            ),
            BottomSheetChild(
              title: ScreenDict.addDebt.get(isRpg),
              subtitle: ScreenDict.addDebt.description ?? "",
              color: AppColors.error,
              icon: ScreenDict.addDebt.icon(isRpg),
              onTap: () {
                Navigator.pop(con);
                _openAddDebtModal(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final billController = context.watch<BillController>();
    final transactionController = context.watch<TransactionController>();

    final isRpg = settingsController.isRpgMode;

    final billTransaction = transactionController.billTransaction;
    final bills = billController.bills;
    final debts = billController.debts;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            ScreenDict.billsMaster.get(isRpg),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: FaIcon(ScreenDict.addIcon.get(isRpg), size: 20),
              onPressed: () => _showActionPopup(context, isRpg),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: ScreenDict.billsActive.get(isRpg)),
              Tab(text: ScreenDict.billsMaster.get(isRpg)),
              Tab(text: ScreenDict.debtsMaster.get(isRpg)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ActiveBillsTab(
              data: billTransaction,
              isRpg: isRpg,
              onTap: (transaction) =>
                  _openActiveBillModal(context, transaction),
            ),
            BillsTab(
              data: bills,
              isRpg: isRpg,
              onTapCard: (bill) => _openBillDetail(context, bill, isRpg),
            ),
            DebtsTab(
              data: debts,
              isRpg: isRpg,
              onTapCard: (debt) => _openDebtDetail(context, debt, isRpg),
            ),
          ],
        ),
      ),
    );
  }
}
