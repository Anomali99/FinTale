import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/history_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/global_messenger.dart';
import '../../../models/transaction_model.dart';
import '../../../widgets/filter_bottom_sheet.dart';
import '../../../widgets/month_filter.dart';
import '../widgets/cash_flow_card.dart';
import '../widgets/section_history.dart';
import '../widgets/transaction_detail_modal.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _openFilter(BuildContext context) async {
    final historyController = context.read<HistoryController>();
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: FilterBottomSheet(
          startDate: historyController.customStartDate,
          endDate: historyController.customEndDate,
          selectedTypes: historyController.selectedTypes,
          selectedWallets: historyController.selectedWallets,
        ),
      ),
    );

    if (result != null && context.mounted) {
      if (result['isReset']) {
        historyController.resetFilter();
      } else {
        historyController.updateFilter(
          result['startDate'],
          result['endDate'],
          result['selectedTypes'],
          result['selectedWallets'],
        );
      }
      await historyController.applyFilter();
      GlobalMessenger.showMessage(
        context,
        message: UiDict.applyFilterNotif,
        isSuccess: true,
      );
    }
  }

  void _openDetail(
    BuildContext context,
    TransactionModel? transaction,
    bool isRpg,
  ) async {
    if (transaction != null && context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            TransactionDetailModal(transaction: transaction, isRpg: isRpg),
      );
    }
  }

  String getTitleMonth({
    required DateTime selectedMonth,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    if (customStartDate == null && customEndDate == null) {
      return DateFormat('MMMM yyyy').format(selectedMonth);
    } else {
      String result = DateFormat('dd MMMM yyyy').format(customStartDate!);
      if (customEndDate != null && customStartDate != customEndDate) {
        result += ' - ';
        result += DateFormat('dd MMMM yyyy').format(customEndDate);
      }
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final settingsController = context.watch<SettingsController>();
    final transactionController = context.watch<TransactionController>();
    final historyController = context.watch<HistoryController>();
    final colorScheme = Theme.of(context).colorScheme;

    final isRpg = settingsController.isRpgMode;

    final income = transactionController.income;
    final expense = transactionController.expense;

    final selectedMonth = historyController.selectedMonth;
    final groupedTransactions = historyController.groupedTransactions;
    final customStartDate = historyController.customStartDate;
    final customEndDate = historyController.customEndDate;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UiDict.menuHistory.get(isRpg),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.filter, size: 18),
            onPressed: () => _openFilter(context),
          ),
          IconButton(
            icon: FaIcon(
              UiDict.menuAnalytics.icon(isRpg),
              size: 20,
              color: colorScheme.primary,
            ),
            onPressed: () async {
              await userController.processMonthlyReview(context);
              await userController.loadData();
              Navigator.pushNamed(context, '/analytics');
            },
            tooltip: UiDict.menuAnalytics.get(isRpg),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  MonthFilter(
                    selected: getTitleMonth(
                      selectedMonth: selectedMonth,
                      customStartDate: customStartDate,
                      customEndDate: customEndDate,
                    ),
                    onPrev: historyController.onPrev,
                    onNext: historyController.onNext,
                    enabled: customStartDate == null && customEndDate == null,
                  ),

                  const SizedBox(height: 16),

                  CashFlowCard(
                    totalIncome: income,
                    totalExpense: expense,
                    isRpg: isRpg,
                  ),
                ],
              ),
            ),
          ),

          if (groupedTransactions.isNotEmpty) ...[
            for (var entry in groupedTransactions.entries)
              SliverToBoxAdapter(
                child: SectionHistory(
                  title: entry.key,
                  transactions: entry.value,
                  onTap: (value) => _openDetail(context, value, isRpg),
                  isRpg: isRpg,
                ),
              ),
          ] else ...[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      UiDict.menuHistory.icon(isRpg),
                      size: 48,
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      UiDict.getEmptyDesc(
                        UiDict.menuHistory.get(isRpg).toLowerCase(),
                        isRpg: isRpg,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
