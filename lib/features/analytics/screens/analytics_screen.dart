import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/analytics_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/models/analytic_model.dart';
import '../../../core/utils/global_messenger.dart';
import '../../../widgets/filter_bottom_sheet.dart';
import '../../../widgets/month_filter.dart';
import '../widgets/detail_card.dart';
import '../widgets/donut_chart.dart';
import '../widgets/overview_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  void _openFilter(BuildContext context) async {
    final analyticsController = context.read<AnalyticsController>();
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: FilterBottomSheet(
          startDate: analyticsController.customStartDate,
          endDate: analyticsController.customEndDate,
          selectedWallets: analyticsController.selectedWallets,
          selectedCategories: analyticsController.selectedCategories,
          features: FilterFeatures(type: false),
        ),
      ),
    );

    if (result != null && context.mounted) {
      if (result['isReset']) {
        analyticsController.resetFilter();
      } else {
        analyticsController.updateFilter(
          result['startDate'],
          result['endDate'],
          result['selectedCategories'],
          result['selectedWallets'],
        );
      }
      await analyticsController.applyFilter();
      GlobalMessenger.showMessage(
        context,
        message: UiDict.applyFilterNotif,
        isSuccess: true,
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
    final settingsController = context.watch<SettingsController>();
    final transactionController = context.watch<TransactionController>();
    final analyticsController = context.watch<AnalyticsController>();
    final colorScheme = Theme.of(context).colorScheme;

    final isRpg = settingsController.isRpgMode;

    final totalIncome = transactionController.totalIncome;
    final totalExpense = transactionController.totalExpense;
    final totalInvest = transactionController.totalInvest;

    final showExpense = analyticsController.showExpense;
    final touchedIndex = analyticsController.touchedIndex;
    final selectedMonth = analyticsController.selectedMonth;
    final customStartDate = analyticsController.customStartDate;
    final customEndDate = analyticsController.customEndDate;

    final activeData = showExpense
        ? transactionController.detailExpense
        : transactionController.detailInvest;
    final activeTotal = showExpense ? totalExpense : totalInvest;
    final activeColor = showExpense ? colorScheme.error : colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UiDict.menuAnalytics.get(isRpg),
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
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          MonthFilter(
            selected: getTitleMonth(
              selectedMonth: selectedMonth,
              customStartDate: customStartDate,
              customEndDate: customEndDate,
            ),
            onPrev: analyticsController.onPrev,
            onNext: analyticsController.onNext,
            enabled: customStartDate == null && customEndDate == null,
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
              color: colorScheme.surfaceContainerHighest,
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
                            ? colorScheme.error.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: showExpense
                              ? colorScheme.error.withOpacity(0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        ScreenDict.breakdownExpense.get(isRpg),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: showExpense
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
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
                            ? colorScheme.primary.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !showExpense
                              ? colorScheme.primary.withOpacity(0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        ScreenDict.breakdownInvest.get(isRpg),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !showExpense
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
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

              return DetailCard(
                data: data,
                activeTotal: activeTotal,
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
                      UiDict.menuAnalytics.icon(isRpg),
                      size: 48,
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      UiDict.getEmptyDesc(
                        UiDict.menuAnalytics.get(isRpg).toLowerCase(),
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
        ],
      ),
    );
  }
}
