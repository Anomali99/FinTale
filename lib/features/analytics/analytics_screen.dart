import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/category_dict.dart';
import '../../core/constants/history_dict.dart';
import '../../core/constants/menu_dict.dart';
import '../../core/dummy/dummy_data.dart';
import '../../core/theme/mode_provider.dart';
import '../../core/utils/time_formatter.dart';
import '../../models/transaction_detail_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/month_filter.dart';
import 'widgets/detail_card.dart';
import 'widgets/donut_chart.dart';
import 'widgets/overview_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final List<TransactionModel> transactions = DummyData.transactions
      .where((transaction) => transaction.status == StatusType.paid)
      .toList();
  DateTime _selectedMonth = DateTime(2026, 4);
  bool _showExpense = true;
  int _touchedIndex = -1;

  late List<AnalyticCategory> expenseCategories;
  late List<AnalyticCategory> investCategories;

  List<TransactionModel> getGroupedTransactions() {
    int startOfMonth = TimeFormatter.getStartOfMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    int endOfMonth = TimeFormatter.getEndOfMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    List<TransactionModel> filteredByMonth = transactions.where((trx) {
      return trx.dateTimestamp != null &&
          trx.dateTimestamp! >= startOfMonth &&
          trx.dateTimestamp! <= endOfMonth;
    }).toList();

    return filteredByMonth;
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;
    BigInt totalIncome = BigInt.zero;
    BigInt totalExpense = BigInt.zero;
    BigInt totalInvest = BigInt.zero;

    Map<TransactionCategory, BigInt> tempExpenseMap = {};
    Map<TransactionCategory, BigInt> tempInvestMap = {};

    for (TransactionModel transaction in getGroupedTransactions()) {
      for (TransactionDetailModel detail in transaction.detailTransaction) {
        if (transaction.type == TransactionType.income &&
            detail.flow == FlowType.income) {
          totalIncome += detail.amount;
        } else if (detail.flow == FlowType.expense) {
          if (detail.category == TransactionCategory.investment) {
            totalInvest += detail.amount;
            tempInvestMap[detail.category] =
                (tempInvestMap[detail.category] ?? BigInt.zero) + detail.amount;
          } else {
            totalExpense += detail.amount;
            tempExpenseMap[detail.category] =
                (tempExpenseMap[detail.category] ?? BigInt.zero) +
                detail.amount;
          }
        }
      }
    }

    expenseCategories = tempExpenseMap.entries.map((entry) {
      return AnalyticCategory(
        category: CategoryDict.getByTransactionCategory(entry.key),
        amount: entry.value,
      );
    }).toList();

    investCategories = tempInvestMap.entries.map((entry) {
      return AnalyticCategory(
        category: CategoryDict.getByTransactionCategory(entry.key),
        amount: entry.value,
      );
    }).toList();

    final activeData = _showExpense ? expenseCategories : investCategories;
    final activeTotal = _showExpense ? totalExpense : totalInvest;
    final activeColor = _showExpense ? AppColors.error : AppColors.primary;

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
            selected: DateFormat('MMMM yyyy').format(_selectedMonth),
            onPrev: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
            onNext: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
          ),

          const SizedBox(height: 24),

          Text(
            HistoryDict.macroOverview.get(isRpg),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),

          const SizedBox(height: 12),

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
                    onTap: () => setState(() {
                      _showExpense = true;
                      _touchedIndex = -1;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _showExpense
                            ? AppColors.error.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showExpense
                              ? AppColors.error.withOpacity(0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        HistoryDict.breakdownExpense.get(isRpg),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _showExpense
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
                    onTap: () => setState(() {
                      _showExpense = false;
                      _touchedIndex = -1;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_showExpense
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_showExpense
                              ? AppColors.primary.withOpacity(0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        HistoryDict.breakdownInvest.get(isRpg),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_showExpense
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

          SizedBox(
            height: 220,
            child: DonutChart(
              activeData: activeData,
              activeTotal: activeTotal,
              showExpense: _showExpense,
              isRpg: isRpg,
              touchedIndex: _touchedIndex,
              activeColor: activeColor,
              onTouch: (index) {
                setState(() {
                  _touchedIndex = index;
                });
              },
            ),
          ),
          const SizedBox(height: 32),

          Text(
            HistoryDict.topExpenses.get(isRpg),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ...activeData.asMap().entries.map((entry) {
            int index = entry.key;
            AnalyticCategory data = entry.value;
            double percentage = data.amount / activeTotal;

            return DetailCard(
              data: data,
              percentage: percentage,
              isSelected: _touchedIndex == index,
              isRpg: isRpg,
            );
          }),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
