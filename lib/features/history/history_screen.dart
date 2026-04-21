import 'package:fintale/features/analytics/analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dictionary.dart';
import '../../core/theme/mode_provider.dart';
import '../../widgets/month_filter.dart';
import 'widgets/cash_flow_card.dart';
import 'widgets/transaction_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final String _selectedMonth = "April 2026";

  void _navigateToAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          MenuDict.history.get(isRpg),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: FaIcon(HistoryDict.filterIcon.get(isRpg), size: 18),
            onPressed: () => {
              /* TODO: Buka filter */
            },
            tooltip: HistoryDict.filter.get(isRpg),
          ),
          IconButton(
            icon: FaIcon(
              HistoryDict.analyticsIcon.get(isRpg),
              size: 20,
              color: AppColors.primary,
            ),
            onPressed: () => _navigateToAnalytics(context),
            tooltip: HistoryDict.analytics.get(isRpg),
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
                  MonthFilter(selected: _selectedMonth),

                  const SizedBox(height: 16),

                  CashFlowCard(isRpg: isRpg),
                ],
              ),
            ),
          ),

          _buildDateHeader('Hari Ini, 19 April 2026'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const TransactionCard(
                  type: TransactionType.income,
                  title: 'Gaji Freelance',
                  subtitle: 'Masuk ke: Bank BCA',
                  amount: 2500000,
                  icon: FontAwesomeIcons.briefcase,
                ),
                TransactionCard(
                  type: TransactionType.expense,
                  title: 'Makan Siang (Nasi Padang)',
                  subtitle: 'Dari: GoPay',
                  amount: 45000,
                  icon: FontAwesomeIcons.burger,
                ),
                TransactionCard(
                  type: TransactionType.transfer,
                  title: HistoryDict.internalTransfer.get(isRpg),
                  subtitle: 'Bank BCA ➔ GoPay',
                  amount: 500000,
                  adminFee: 6500,
                  icon: HistoryDict.transferLogIcon.get(isRpg),
                ),
              ]),
            ),
          ),

          _buildDateHeader('Kemarin, 18 April 2026'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const TransactionCard(
                  type: TransactionType.expense,
                  title: 'Tagihan Listrik Rumah',
                  subtitle: 'Dari: Bank Mandiri',
                  amount: 350000,
                  icon: FontAwesomeIcons.bolt,
                ),
                const TransactionCard(
                  type: TransactionType.expense,
                  title: 'Cicilan KPR',
                  subtitle: 'Dari: Bank BCA',
                  amount: 1500000,
                  icon: FontAwesomeIcons.house,
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String dateText) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          bottom: 12.0,
          top: 8.0,
        ),
        child: Text(
          dateText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
