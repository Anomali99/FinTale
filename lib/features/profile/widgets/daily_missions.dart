import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/profile_dict.dart';
import '../../../models/user_progress_model.dart';

class DailyMissions extends StatelessWidget {
  final UserProgressModel progress;
  final bool isRpg;
  const DailyMissions({super.key, required this.progress, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dailyMissions = [
      {
        "icon": FontAwesomeIcons.penToSquare,
        "title": ProfileDict.recordTransaction.get(isRpg),
        "xp": '+10 XP',
        "subtitle": 'Progress: ${progress.dailyTransactionCount} / 3',
        "isDone": progress.dailyTransactionCount >= 3,
      },
      {
        "icon": FontAwesomeIcons.wallet,
        "title": ProfileDict.dailyBudgetCap.get(isRpg),
        "xp": '+25 XP',
        "subtitle": 'Limit: 1x',
        "isDone": progress.isDailyBudgetClaimed,
      },
    ];
    final List<Map<String, dynamic>> weeklyMissions = [
      {
        "icon": FontAwesomeIcons.calendarCheck,
        "title": ProfileDict.weeklyCheckin.get(isRpg),
        "xp": '+100 XP',
        "subtitle": 'Limit: 1x',
        "isDone": progress.isWeeklyCheckInClaimed,
      },
      {
        "icon": FontAwesomeIcons.chartLine,
        "title": ProfileDict.consistentBudgeting.get(isRpg),
        "xp": '+150 XP',
        "subtitle": 'Limit: 1x',
        "isDone": progress.isWeeklyBudgetClaimed,
      },
    ];
    final List<Map<String, dynamic>> monthlyMissions = [
      {
        "icon": FontAwesomeIcons.piggyBank,
        "title": ProfileDict.monthlySavingsGoal.get(isRpg),
        "xp": '+500 XP',
        "subtitle": 'Limit: 1x',
        "isDone": progress.isMonthlySavingsClaimed,
      },
      {
        "icon": FontAwesomeIcons.fileInvoiceDollar,
        "title": ProfileDict.debtPayment.get(isRpg),
        "xp": '+300 XP',
        "subtitle": 'Limit: 1x',
        "isDone": progress.isMonthlyDebtClaimed,
      },
      {
        "icon": FontAwesomeIcons.chartPie,
        "title": ProfileDict.monthlyReview.get(isRpg),
        "xp": '+200 XP',
        "subtitle": 'Limit: 1x',
        "isDone": progress.isMonthlyReviewClaimed,
      },
    ];
    final List<Map<String, dynamic>> specialMissions = [
      {
        "icon": FontAwesomeIcons.flagCheckered,
        "title": ProfileDict.firstTransaction.get(isRpg),
        "xp": '+100 XP',
        "subtitle": 'Limit: 1x',
        "isDone": progress.isFirstTransactionClaimed,
      },
      {
        "icon": FontAwesomeIcons.buildingColumns,
        "title": ProfileDict.createWallet.get(isRpg),
        "xp": '+50 XP',
        "subtitle": 'Progress: ${progress.walletCreatedCount} / 3',
        "isDone": progress.walletCreatedCount >= 3,
      },
      {
        "icon": FontAwesomeIcons.sliders,
        "title": ProfileDict.setAllocation.get(isRpg),
        "xp": '+200 XP',
        "subtitle": 'Limit: 1x',
        "isDone": progress.isAllocationSetClaimed,
      },
    ];

    dailyMissions.sort((a, b) {
      if (a['isDone'] == b['isDone']) return 0;
      return a['isDone'] ? 1 : -1;
    });
    weeklyMissions.sort((a, b) {
      if (a['isDone'] == b['isDone']) return 0;
      return a['isDone'] ? 1 : -1;
    });
    monthlyMissions.sort((a, b) {
      if (a['isDone'] == b['isDone']) return 0;
      return a['isDone'] ? 1 : -1;
    });
    specialMissions.sort((a, b) {
      if (a['isDone'] == b['isDone']) return 0;
      return a['isDone'] ? 1 : -1;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Daily Mission'),
        const SizedBox(height: 12),
        for (Map<String, dynamic> mission in dailyMissions)
          _buildTaskItem(
            icon: mission['icon'],
            title: mission['title'],
            xp: mission['xp'],
            subtitle: mission['subtitle'],
            isDone: mission['isDone'],
          ),
        const SizedBox(height: 20),
        _buildSectionHeader('Weekly Mission'),
        const SizedBox(height: 12),
        for (Map<String, dynamic> mission in weeklyMissions)
          _buildTaskItem(
            icon: mission['icon'],
            title: mission['title'],
            xp: mission['xp'],
            subtitle: mission['subtitle'],
            isDone: mission['isDone'],
          ),
        const SizedBox(height: 20),
        _buildSectionHeader('Monthly Mission'),
        const SizedBox(height: 12),
        for (Map<String, dynamic> mission in monthlyMissions)
          _buildTaskItem(
            icon: mission['icon'],
            title: mission['title'],
            xp: mission['xp'],
            subtitle: mission['subtitle'],
            isDone: mission['isDone'],
          ),
        const SizedBox(height: 20),
        _buildSectionHeader('Special Mission'),
        const SizedBox(height: 12),
        for (Map<String, dynamic> mission in specialMissions)
          _buildTaskItem(
            icon: mission['icon'],
            title: mission['title'],
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

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    ),
  );
}
