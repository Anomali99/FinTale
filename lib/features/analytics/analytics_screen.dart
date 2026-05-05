import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/analytics_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/history_dict.dart';
import '../../core/constants/menu_dict.dart';
import '../../core/models/analytic_model.dart';
import '../../widgets/month_filter.dart';
import 'widgets/detail_card.dart';
import 'widgets/donut_chart.dart';
import 'widgets/overview_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final transactionController = context.watch<TransactionController>();
    final analyticsController = context.watch<AnalyticsController>();

    final isRpg = settingsController.isRpgMode;

    final totalIncome = transactionController.totalIncome;
    final totalExpense = transactionController.totalExpense;
    final totalInvest = transactionController.totalInvest;

    final showExpense = analyticsController.showExpense;
    final touchedIndex = analyticsController.touchedIndex;
    final selectedMonth = analyticsController.selectedMonth;

    final activeData = showExpense
        ? transactionController.detailExpense
        : transactionController.detailInvest;
    final activeTotal = showExpense ? totalExpense : totalInvest;
    final activeColor = showExpense ? AppColors.error : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          MenuDict.analytics.get(isRpg),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          MonthFilter(
            selected: DateFormat('MMMM yyyy').format(selectedMonth),
            onPrev: analyticsController.onPrev,
            onNext: analyticsController.onNext,
          ),

          const SizedBox(height: 24),

          OverviewCard(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            totalInvest: totalInvest,
            isRpg: isRpg,
          ),

          const SizedBox(height: 32),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => analyticsController.onTapExpense(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: showExpense
                            ? AppColors.error.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: showExpense
                              ? AppColors.error.withOpacity(0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        HistoryDict.breakdownExpense.get(isRpg),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: showExpense
                              ? AppColors.error
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => analyticsController.onTapExpense(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !showExpense
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !showExpense
                              ? AppColors.primary.withOpacity(0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        HistoryDict.breakdownInvest.get(isRpg),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !showExpense
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          if (activeData.isNotEmpty) ...[
            SizedBox(
              height: 220,
              child: DonutChart(
                activeData: activeData,
                activeTotal: activeTotal,
                showExpense: showExpense,
                isRpg: isRpg,
                touchedIndex: touchedIndex,
                activeColor: activeColor,
                onTouch: analyticsController.onTouchIndex,
              ),
            ),
            const SizedBox(height: 32),

            ...activeData.entries.map((entry) {
              int index = entry.key;
              AnalyticModel data = entry.value;
              double percentage = data.amount / activeTotal;

              return DetailCard(
                data: data,
                percentage: percentage,
                isSelected: touchedIndex == index,
                isRpg: isRpg,
              );
            }),
          ] else ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      MenuDict.analytics.icon(isRpg),
                      size: 48,
                      color: AppColors.surfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      HistoryDict.emptyAnalytics,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
