import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dictionary.dart';
import '../../core/theme/mode_provider.dart';
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
  final String _selectedMonth = "April 2026";
  bool _showExpense = true;
  int _touchedIndex = -1;

  final double totalIncome = 10000000;
  final double totalExpense = 4000000;
  final double totalInvest = 3000000;

  late List<CategoryData> expenseCategories;
  late List<CategoryData> investCategories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;

    expenseCategories = [
      CategoryData(
        CategoryDict.catFood.get(isRpg),
        1800000,
        Colors.redAccent,
        CategoryDict.catFoodIcon.get(isRpg),
      ),
      CategoryData(
        CategoryDict.catBills.get(isRpg),
        1200000,
        Colors.orangeAccent,
        CategoryDict.catBillsIcon.get(isRpg),
      ),
      CategoryData(
        CategoryDict.catTransport.get(isRpg),
        600000,
        Colors.purpleAccent,
        CategoryDict.catTransportIcon.get(isRpg),
      ),
      CategoryData(
        CategoryDict.catEntertainment.get(isRpg),
        400000,
        Colors.pinkAccent,
        CategoryDict.catEntertainmentIcon.get(isRpg),
      ),
    ];

    investCategories = [
      CategoryData(
        ArmoryDict.fighter.get(isRpg),
        1500000,
        Colors.blueAccent,
        ArmoryDict.fighterIcon.get(isRpg),
      ),
      CategoryData(
        ArmoryDict.tanker.get(isRpg),
        1000000,
        Colors.teal,
        ArmoryDict.tankerIcon.get(isRpg),
      ),
      CategoryData(
        ArmoryDict.assassin.get(isRpg),
        500000,
        Colors.deepPurpleAccent,
        ArmoryDict.assassinIcon.get(isRpg),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;

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
          MonthFilter(selected: _selectedMonth),

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
            CategoryData data = entry.value;
            double percentage = data.amount / activeTotal;

            return DetailCard(
              data: data,
              percentage: percentage,
              isSelected: _touchedIndex == index,
            );
          }),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
