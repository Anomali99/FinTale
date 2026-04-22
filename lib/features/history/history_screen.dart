import 'package:fintale/features/analytics/analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/menu_dict.dart';
import '../../core/constants/shared_dict.dart';
import '../../core/dummy/dummy_data.dart';
import '../../core/theme/mode_provider.dart';
import '../../core/utils/time_formatter.dart';
import '../../models/transaction_detail_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/month_filter.dart';
import 'widgets/cash_flow_card.dart';
import 'widgets/section_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<TransactionModel> transactions = DummyData.transactions
      .where((transaction) => transaction.status == StatusType.paid)
      .toList();
  DateTime _selectedMonth = DateTime(2026, 4);

  void _navigateToAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
    );
  }

  Map<String, List<TransactionModel>> getGroupedTransactions() {
    Map<String, List<TransactionModel>> groupedData = {};

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

    for (TransactionModel trx in filteredByMonth) {
      String dateKey = TimeFormatter.formatShort(trx.dateTimestamp!);

      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }

      groupedData[dateKey]!.add(trx);
    }

    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;
    BigInt totalIncome = BigInt.zero;
    BigInt totalExpense = BigInt.zero;
    for (TransactionModel transaction in transactions) {
      for (TransactionDetailModel detail in transaction.detailTransaction) {
        if (transaction.type == TransactionType.income &&
            detail.flow == FlowType.income) {
          totalIncome += detail.amount;
        } else if (detail.flow == FlowType.expense) {
          totalExpense += detail.amount;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          MenuDict.history.get(isRpg),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: FaIcon(SharedDict.filter.icon(isRpg), size: 18),
            onPressed: () => {
              /* TODO: Buka filter */
            },
            tooltip: SharedDict.filter.get(isRpg),
          ),
          IconButton(
            icon: FaIcon(
              MenuDict.analytics.icon(isRpg),
              size: 20,
              color: AppColors.primary,
            ),
            onPressed: () => _navigateToAnalytics(context),
            tooltip: MenuDict.analytics.get(isRpg),
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

                  const SizedBox(height: 16),

                  CashFlowCard(
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                    isRpg: isRpg,
                  ),
                ],
              ),
            ),
          ),

          for (var entry in getGroupedTransactions().entries)
            SliverToBoxAdapter(
              child: SectionHistory(
                title: entry.key,
                transactions: entry.value,
                isRpg: isRpg,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
