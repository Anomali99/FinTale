import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/history_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/ui_dict.dart';
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
      historyController.updateFilter(
        result['startDate'],
        result['endDate'],
        result['selectedTypes'],
        result['selectedWallets'],
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

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final transactionController = context.watch<TransactionController>();
    final historyController = context.watch<HistoryController>();

    final isRpg = settingsController.isRpgMode;

    final income = transactionController.income;
    final expense = transactionController.expense;

    final selectedMonth = historyController.selectedMonth;
    final groupedTransactions = historyController.groupedTransactions;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UiDict.menuHistory.get(isRpg),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
              color: AppColors.primary,
            ),
            onPressed: () => Navigator.pushNamed(context, '/analytics'),
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
                    selected: DateFormat('MMMM yyyy').format(selectedMonth),
                    onPrev: historyController.onPrev,
                    onNext: historyController.onNext,
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
                      color: AppColors.surfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      UiDict.getEmptyDesc(
                        UiDict.menuHistory.get(isRpg).toLowerCase(),
                        isRpg: isRpg,
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
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
