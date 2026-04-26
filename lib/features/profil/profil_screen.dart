import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/profil_dict.dart';
import '../../core/constants/skill_dict.dart';
import '../../core/dummy/dummy_data.dart';
import '../../core/theme/mode_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/user_model.dart';
import 'widgets/profil_card.dart';
import 'widgets/skill_tree.dart';
import 'widgets/stat_radar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserModel userData = DummyData.user;

  @override
  Widget build(BuildContext context) {
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circleInfo, size: 20),
            onPressed: () => {} /* Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ) */,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          ProfilCard(user: userData, isRpg: isRpg, editName: () {}),
          const SizedBox(height: 32),

          _buildAllocationStats(context, userData, isRpg),
          const SizedBox(height: 24),

          _buildSettingCard(
            FontAwesomeIcons.bolt,
            'Daily Spending Limit',
            '${CurrencyFormatter.convertToIdr(userData.dailyLimit)}/day',
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            SkillDict.emergency.icon(isRpg),
            SkillDict.emergency.get(isRpg),
            '${CurrencyFormatter.convertToIdr(userData.emergencyTotal)}/${CurrencyFormatter.convertToIdr(userData.emergencyAmount)}',
          ),
          const SizedBox(height: 32),

          _buildSectionHeader(ProfilDict.missions.get(isRpg)),
          const SizedBox(height: 12),
          _buildTaskItem(
            icon: FontAwesomeIcons.penNib,
            title: isRpg ? 'Daily Combat Log' : 'Record Transaction',
            xp: '+10 XP',
            progress: 3,
            max: 5,
            isRpg: isRpg,
          ),
          _buildTaskItem(
            icon: FontAwesomeIcons.shieldHalved,
            title: isRpg ? 'Castle Defense' : 'Daily Budget Cap',
            xp: '+20 XP',
            progress: 1,
            max: 1,
            isRpg: isRpg,
            subtitle: 'Limit: Rp 50.000 / day',
          ),
          _buildTaskItem(
            icon: FontAwesomeIcons.gem,
            title: isRpg ? 'Treasure Hunt' : 'Monthly Savings',
            xp: '+500 XP',
            progress: 0,
            max: 1,
            isRpg: isRpg,
            isMonthly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationStats(
    BuildContext context,
    UserModel user,
    bool isRpg,
  ) {
    double getSkillPercentage(String key) {
      double? percentage = user.skillAllocations[key];
      if (percentage != null) {
        if (key != 'emergency') {
          if (user.emergencyAmount == user.emergencyTotal) {
            return (100 - percentage) / 100;
          } else {
            return percentage / 100;
          }
        }

        if (key != 'payDebt') {
          return percentage / 100;
        }

        return (100 - percentage) / 100;
      }

      return 0.0;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SkillTree()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ProfilDict.stats.get(isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    StatRadar(
                      stats: [
                        getSkillPercentage('living'),
                        getSkillPercentage('payDebt'),
                        getSkillPercentage('emergency'),
                        getSkillPercentage('investment'),
                      ],
                      color: AppColors.primary,
                    ),

                    const FaIcon(
                      FontAwesomeIcons.khanda,
                      size: 16,
                      color: Colors.white24,
                    ),
                  ],
                ),

                const SizedBox(width: 32),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statRow(
                        SkillDict.dailyParent.get(isRpg),
                        '${user.skillAllocations['living']?.toInt().toString() ?? "0"}%',
                        SkillDict.dailyParent.color ?? Colors.blue,
                      ),
                      _statRow(
                        SkillDict.debt.get(isRpg),
                        '${user.skillAllocations['payDebt']?.toInt().toString() ?? "0"}%',
                        SkillDict.debt.color ?? Colors.blue,
                      ),
                      _statRow(
                        SkillDict.emergency.get(isRpg),
                        '${user.skillAllocations['emergency']?.toInt().toString() ?? "0"}%',
                        SkillDict.emergency.color ?? Colors.blue,
                      ),
                      _statRow(
                        SkillDict.investment.get(isRpg),
                        '${user.skillAllocations['investment']?.toInt().toString() ?? "0"}%',
                        SkillDict.investment.color ?? Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String val, Color col) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            val,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(FaIconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: Text('EDIT')),
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

  Widget _buildTaskItem({
    required FaIconData icon,
    required String title,
    required String xp,
    required int progress,
    required int max,
    required bool isRpg,
    String? subtitle,
    bool isMonthly = false,
  }) {
    bool isDone = progress >= max;

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
                Text(
                  subtitle ??
                      (isMonthly
                          ? 'Resets Monthly'
                          : 'Progress: $progress / $max'),
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
