import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/user_progress_model.dart';

class DailyMissions extends StatelessWidget {
  final UserProgressModel progress;
  const DailyMissions({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> missions = [
      {
        "icon": FontAwesomeIcons.penToSquare,
        "title": 'Record Transaction',
        "frequency": 'Daily',
        "xp": '+10 XP',
        "subtitle": 'Progress: ${progress.dailyTransactionCount} / 3',
        "isDone": progress.dailyTransactionCount >= 3,
      },
      {
        "icon": FontAwesomeIcons.wallet,
        "title": 'Daily Budget Cap',
        "frequency": 'Daily',
        "xp": '+25 XP',
        "subtitle": 'Limit: 1x / day',
        "isDone": progress.isDailyBudgetClaimed,
      },
      {
        "icon": FontAwesomeIcons.calendarCheck,
        "title": 'Weekly Check-in',
        "frequency": 'Weekly',
        "xp": '+100 XP',
        "subtitle": 'Limit: 1x / week',
        "isDone": progress.isWeeklyCheckInClaimed,
      },
      {
        "icon": FontAwesomeIcons.chartLine,
        "title": 'Consistent Budgeting',
        "frequency": 'Weekly',
        "xp": '+150 XP',
        "subtitle": 'Limit: 1x / week',
        "isDone": progress.isWeeklyBudgetClaimed,
      },
      {
        "icon": FontAwesomeIcons.piggyBank,
        "title": 'Monthly Savings Goal',
        "frequency": 'Monthly',
        "xp": '+500 XP',
        "subtitle": 'Limit: 1x / month',
        "isDone": progress.isMonthlySavingsClaimed,
      },
      {
        "icon": FontAwesomeIcons.fileInvoiceDollar,
        "title": 'Debt Payment',
        "frequency": 'Monthly',
        "xp": '+300 XP',
        "subtitle": 'Limit: 1x / month',
        "isDone": progress.isMonthlyDebtClaimed,
      },
      {
        "icon": FontAwesomeIcons.chartPie,
        "title": 'Monthly Review',
        "frequency": 'Monthly',
        "xp": '+200 XP',
        "subtitle": 'Limit: 1x / month',
        "isDone": progress.isMonthlyReviewClaimed,
      },
      {
        "icon": FontAwesomeIcons.flagCheckered,
        "title": 'First Transaction',
        "frequency": 'Unique',
        "xp": '+100 XP',
        "subtitle": 'Limit: 1x',
        "isDone": progress.isFirstTransactionClaimed,
      },
      {
        "icon": FontAwesomeIcons.buildingColumns,
        "title": 'Create Wallet',
        "frequency": 'Unique',
        "xp": '+50 XP',
        "subtitle": 'Progress: ${progress.walletCreatedCount} / 3',
        "isDone": progress.walletCreatedCount >= 3,
      },
      {
        "icon": FontAwesomeIcons.sliders,
        "title": 'Set Allocation',
        "frequency": 'Unique',
        "xp": '+200 XP',
        "subtitle": 'Limit: 1x',
        "isDone": progress.isAllocationSetClaimed,
      },
    ];

    missions.sort((a, b) {
      if (a['isDone'] == b['isDone']) return 0;
      return a['isDone'] ? 1 : -1;
    });

    return Column(
      children: [
        for (Map<String, dynamic> mission in missions)
          _buildTaskItem(
            icon: mission['icon'],
            title: mission['title'],
            frequency: mission['frequency'],
            xp: mission['xp'],
            subtitle: mission['subtitle'],
            isDone: mission['isDone'],
          ),
      ],
    );
  }

  Widget _buildTaskItem({
    required FaIconData icon,
    required String title,
    required String frequency,
    required String xp,
    String? subtitle,
    bool isDone = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(isDone ? 0.5 : 1.0),
        borderRadius: BorderRadius.circular(16),
        border: isDone ? null : Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 20,
            color: isDone ? Colors.grey : AppColors.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : Colors.white,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            isDone ? 'COMPLETED' : xp,
            style: TextStyle(
              fontSize: 10,
              color: isDone ? Colors.green : Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
