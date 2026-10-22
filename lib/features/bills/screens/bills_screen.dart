import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/analytics_controller.dart';
import '../../../controllers/bill_controller.dart';
import '../../../controllers/history_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/color_extension.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/global_messenger.dart';
import '../../../models/bill_model.dart';
import '../../../models/debt_model.dart';
import '../../../models/receivable_model.dart';
import '../../../models/transaction_model.dart';
import '../../../widgets/custom_bottom_sheet.dart';
import '../../../widgets/custom_tab_bar.dart';
import '../../../widgets/responsive_container.dart';
import '../widgets/active_bills_tab.dart';
import '../widgets/add_bill_modal.dart';
import '../widgets/add_debt_modal.dart';
import '../widgets/bill_detail_modal.dart';
import '../widgets/bills_tab.dart';
import '../widgets/debt_detail_modal.dart';
import '../widgets/debts_tab.dart';
import '../widgets/pay_bill_modal.dart';
import '../widgets/pay_debt_modal.dart';
import '../widgets/receivables_tab.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  void _openReceivableDetail(
    BuildContext context,
    String borrowerName,
    List<ReceivableModel> data,
    bool isRpg,
  ) async {
    final billController = context.read<BillController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();

    final result =
        await Navigator.pushNamed(
              context,
              '/receivable-detail',
              arguments: {"borrowerName": borrowerName, "initialRecords": data},
            )
            as Map<String, dynamic>?;

    if (result != null && context.mounted) {
      List<ReceivableModel> receivables = result['receivables'];
      List<TransactionModel> transactions = result['transactions'];

      final isSuccess = await billController.recordReceivable(
        context,
        transactions: transactions,
        receivable: receivables,
      );

      await historyController.applyFilter();
      await analyticsController.applyFilter();
      if (!context.mounted) return;

      GlobalMessenger.showMessage(
        context,
        message: UiDict.getSaveNotif(
          ScreenDict.receivableMaster.get(isRpg),
          isSuccess: isSuccess,
          isUpdate: true,
        ),
        isSuccess: isSuccess,
      );
    }
  }

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
        if (!context.mounted) return;
        GlobalMessenger.showMessage(
          context,
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
      if (!context.mounted) return;
      GlobalMessenger.showMessage(
        context,
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
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddDebtModal(initialDebt: initialDebt);
      },
    );

    if (result != null && context.mounted) {
      final debt = result['debt'] as DebtModel;
      final transaction = result['transaction'] as TransactionModel?;

      final billController = context.read<BillController>();
      final historyController = context.read<HistoryController>();
      final analyticsController = context.read<AnalyticsController>();
      final transactionController = context.read<TransactionController>();

      bool isSuccess = await billController.createDebt(context, debt);

      if (isSuccess && transaction != null && context.mounted) {
        await transactionController.createTransaction(transaction);
        await historyController.applyFilter();
        await analyticsController.applyFilter();
      }

      if (!context.mounted) return;
      GlobalMessenger.showMessage(
        context,
        message: UiDict.getSaveNotif(
          ScreenDict.debtsMaster.get(isRpg),
          isSuccess: isSuccess,
          isUpdate: initialDebt != null,
        ),
        isSuccess: isSuccess,
      );
    }
  }

  void _openAddReceivableModal(
    BuildContext context, {
    ReceivableModel? initialReceivable,
  }) async {
    final settingsController = context.read<SettingsController>();
    final billController = context.read<BillController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();

    final borrowerNames = billController.borrowerNames;
    final isRpg = settingsController.isRpgMode;

    final result =
        await Navigator.pushNamed(
              context,
              '/add-receivable',
              arguments: {
                "existingNames": borrowerNames,
                "initialReceivable": initialReceivable,
              },
            )
            as Map<String, dynamic>?;

    if (result != null && context.mounted) {
      ReceivableModel receivable = result['receivable'];
      TransactionModel? transaction = result['transaction'];
      bool? useReserved = result['use_reserved'];
      bool generateTransaction = result['generate_transaction'] ?? false;

      bool isSuccess;
      if (generateTransaction && transaction != null) {
        isSuccess = await billController.createReceivable(
          context,
          transaction,
          receivable,
          useReserved: useReserved ?? false,
        );
      } else {
        isSuccess = await billController.createReceivableOnly(
          context,
          receivable,
        );
      }

      await historyController.applyFilter();
      await analyticsController.applyFilter();
      if (!context.mounted) return;

      GlobalMessenger.showMessage(
        context,
        message: UiDict.getSaveNotif(
          ScreenDict.receivableMaster.get(isRpg),
          isSuccess: isSuccess,
          isUpdate: initialReceivable != null,
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
    final homeController = context.read<HomeController>();
    final billController = context.read<BillController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final isRpg = context.read<SettingsController>().isRpgMode;
    final wallets = context.read<WalletController>().allWallets;
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
          context,
          transaction,
          useReserved: useReserved,
        );
        message = ScreenDict.getBillNotif(isSuccess: isSuccess, isRpg: isRpg);
      } else {
        isSuccess = await billController.payDebt(
          context,
          transaction,
          useReserved: useReserved,
        );
        await homeController.usePendingBySector(
          amount: transaction.amount,
          sector: SectorType.payDebt,
        );
        message = ScreenDict.getDebtNotif(isSuccess: isSuccess, isRpg: isRpg);
      }
      await historyController.applyFilter();
      await analyticsController.applyFilter();
      if (!context.mounted) return;
      GlobalMessenger.showMessage(
        context,
        message: message,
        isSuccess: isSuccess,
      );
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
        context,
        transaction,
        useReserved: useReserved,
        checkExisting: false,
      );
      await historyController.applyFilter();
      await analyticsController.applyFilter();
    }
  }

  void _showActionPopup(BuildContext context, bool isRpg) {
    final colorScheme = Theme.of(context).colorScheme;

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
              color: Colors.blueAccent.adapt(context),
              icon: ScreenDict.addBill.icon(isRpg),
              onTap: () {
                Navigator.pop(con);
                _openAddBillModal(context);
              },
            ),
            BottomSheetChild(
              title: ScreenDict.addDebt.get(isRpg),
              subtitle: ScreenDict.addDebt.description ?? "",
              color: colorScheme.error,
              icon: ScreenDict.addDebt.icon(isRpg),
              onTap: () {
                Navigator.pop(con);
                _openAddDebtModal(context);
              },
            ),
            BottomSheetChild(
              title: ScreenDict.addReceivable.get(isRpg),
              subtitle: ScreenDict.addReceivable.description ?? "",
              color: Colors.greenAccent.adapt(context),
              icon: ScreenDict.addReceivable.icon(isRpg),
              onTap: () {
                Navigator.pop(con);
                _openAddReceivableModal(context);
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
    final colorScheme = Theme.of(context).colorScheme;

    final isRpg = settingsController.isRpgMode;

    final billTransaction = transactionController.billTransaction;
    final bills = billController.bills;
    final debts = billController.debts;

    final groupedReceivables = billController.groupedReceivables;

    return DefaultTabController(
      length: 2,
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
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            tabs: [
              Tab(text: ScreenDict.billsMaster.get(isRpg)),
              Tab(text: ScreenDict.debtsMaster.get(isRpg)),
            ],
          ),
        ),

        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            final activeBillsContent = ActiveBillsTab(
              data: billTransaction,
              isRpg: isRpg,
              onTap: (transaction) =>
                  _openActiveBillModal(context, transaction),
            );
            final billsContent = BillsTab(
              data: bills,
              isRpg: isRpg,
              onTapCard: (bill) => _openBillDetail(context, bill, isRpg),
            );

            final debtsContent = DebtsTab(
              data: debts,
              isRpg: isRpg,
              onTapCard: (debt) => _openDebtDetail(context, debt, isRpg),
            );
            final receivablesContent = ReceivablesTab(
              data: groupedReceivables,
              isRpg: isRpg,
              onTapCard: (name, receivable) =>
                  _openReceivableDetail(context, name, receivable, isRpg),
            );

            if (isWide) {
              return TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  ScreenDict.billsActive.get(isRpg),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: activeBillsContent),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  ScreenDict.billsMaster.get(isRpg),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: billsContent),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  ScreenDict.debtsMaster.get(isRpg),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: debtsContent),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  ScreenDict.receivableMaster.get(isRpg),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: receivablesContent),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ResponsiveContainer(
              child: TabBarView(
                children: [
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),

                          child: CustomTabBar(
                            tabs: [
                              ScreenDict.billsActive.get(isRpg),
                              ScreenDict.billsMaster.get(isRpg),
                            ],
                          ),
                        ),

                        Expanded(
                          child: TabBarView(
                            children: [activeBillsContent, billsContent],
                          ),
                        ),
                      ],
                    ),
                  ),

                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),

                          child: CustomTabBar(
                            tabs: [
                              ScreenDict.debtsMaster.get(isRpg),
                              ScreenDict.receivableMaster.get(isRpg),
                            ],
                          ),
                        ),

                        Expanded(
                          child: TabBarView(
                            children: [debtsContent, receivablesContent],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
