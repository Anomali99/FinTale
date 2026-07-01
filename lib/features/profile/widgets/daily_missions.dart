import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/gamification_dict.dart';
import '../../../models/user_model.dart';

class DailyMissions extends StatelessWidget {
  final UserProgressModel progress;
  final bool isRpg;
  const DailyMissions({super.key, required this.progress, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dailyMissions = [
      {
        "icon": GamificationDict.missionRecordTransaction.icon(isRpg),
        "title": GamificationDict.missionRecordTransaction.get(isRpg),
        "xp": GamificationDict.missionRecordTransaction.xp,
        "subtitle": 'Progress: ${progress.dailyTransactionCount} / 3',
        "isDone": progress.dailyTransactionCount >= 3,
      },
      {
        "icon": GamificationDict.missionDailyBudgetCap.icon(isRpg),
        "title": GamificationDict.missionDailyBudgetCap.get(isRpg),
        "xp": GamificationDict.missionDailyBudgetCap.xp,
        "subtitle": 'Limit: 1x',
        "isDone": progress.isDailyBudgetClaimed,
      },
    ];
    final List<Map<String, dynamic>> weeklyMissions = [
      {
        "icon": GamificationDict.missionWeeklyCheckin.icon(isRpg),
        "title": GamificationDict.missionWeeklyCheckin.get(isRpg),
        "xp": GamificationDict.missionWeeklyCheckin.xp,
        "subtitle": 'Limit: 1x',
        "isDone": progress.isWeeklyCheckInClaimed,
      },
      {
        "icon": GamificationDict.missionConsistentBudgeting.icon(isRpg),
        "title": GamificationDict.missionConsistentBudgeting.get(isRpg),
        "xp": GamificationDict.missionConsistentBudgeting.xp,
        "subtitle": 'Limit: 1x',
        "isDone": progress.isWeeklyBudgetClaimed,
      },
    ];
    final List<Map<String, dynamic>> monthlyMissions = [
      {
        "icon": GamificationDict.missionDebtPayment.icon(isRpg),
        "title": GamificationDict.missionDebtPayment.get(isRpg),
        "xp": GamificationDict.missionDebtPayment.xp,
        "subtitle": 'Limit: 1x',
        "isDone": progress.isMonthlyDebtClaimed,
      },
      {
        "icon": GamificationDict.missionMonthlyReview.icon(isRpg),
        "title": GamificationDict.missionMonthlyReview.get(isRpg),
        "xp": GamificationDict.missionMonthlyReview.xp,
        "subtitle": 'Limit: 1x',
        "isDone": progress.isMonthlyReviewClaimed,
      },
    ];
    final List<Map<String, dynamic>> specialMissions = [
      {
        "icon": GamificationDict.missionFirstTransaction.icon(isRpg),
        "title": GamificationDict.missionRecordTransaction.get(isRpg),
        "xp": GamificationDict.missionFirstTransaction.xp,
        "subtitle": 'Limit: 1x',
        "isDone": progress.isFirstTransactionClaimed,
      },
      {
        "icon": GamificationDict.missionCreateWallet.icon(isRpg),
        "title": GamificationDict.missionCreateWallet.get(isRpg),
        "xp": GamificationDict.missionCreateWallet.xp,
        "subtitle": 'Progress: ${progress.walletCreatedCount} / 3',
        "isDone": progress.walletCreatedCount >= 3,
      },
      {
        "icon": GamificationDict.missionSetAllocation.icon(isRpg),
        "title": GamificationDict.missionSetAllocation.get(isRpg),
        "xp": GamificationDict.missionSetAllocation.xp,
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
        _buildSectionHeader(context, GamificationDict.missionDaily),
        const SizedBox(height: 12),
        for (Map<String, dynamic> mission in dailyMissions)
          _buildTaskItem(
            context,
            icon: mission['icon'],
            title: mission['title'],
            xp: mission['xp'],
            subtitle: mission['subtitle'],
            isDone: mission['isDone'],
          ),
        const SizedBox(height: 20),
        _buildSectionHeader(context, GamificationDict.missionWeekly),
        const SizedBox(height: 12),
        for (Map<String, dynamic> mission in weeklyMissions)
          _buildTaskItem(
            context,
            icon: mission['icon'],
            title: mission['title'],
            xp: mission['xp'],
            subtitle: mission['subtitle'],
            isDone: mission['isDone'],
          ),
        const SizedBox(height: 20),
        _buildSectionHeader(context, GamificationDict.missionMonthly),
        const SizedBox(height: 12),
        for (Map<String, dynamic> mission in monthlyMissions)
          _buildTaskItem(
            context,
            icon: mission['icon'],
            title: mission['title'],
            xp: mission['xp'],
            subtitle: mission['subtitle'],
            isDone: mission['isDone'],
          ),
        const SizedBox(height: 20),
        _buildSectionHeader(context, GamificationDict.missionSpecial),
        const SizedBox(height: 12),
        for (Map<String, dynamic> mission in specialMissions)
          _buildTaskItem(
            context,
            icon: mission['icon'],
            title: mission['title'],
            xp: mission['xp'],
            subtitle: mission['subtitle'],
            isDone: mission['isDone'],
          ),
      ],
    );
  }

  Widget _buildTaskItem(
    BuildContext context, {
    required FaIconData icon,
    required String title,
    required String xp,
    String? subtitle,
    bool isDone = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(
          isDone ? 0.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
        border: isDone ? null : Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 20,
            color: isDone ? Colors.grey : colorScheme.primary,
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
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
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

  Widget _buildSectionHeader(BuildContext context, String title) => Text(
    title,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}
