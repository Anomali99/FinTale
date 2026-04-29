import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/profile_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/profile_dict.dart';
import '../../core/constants/skill_dict.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/allocation_model.dart';
import 'widgets/allocation_card.dart';
import 'widgets/edit_modal.dart';
import 'widgets/information.dart';
import 'widgets/profile_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openEditName(BuildContext context, {String? defaultValue}) async {
    final String? result = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return EditModal(
          title: 'Edit Name',
          fieldTitle: 'Name',
          defaultValue: defaultValue,
        );
      },
    );
    if (result != null && context.mounted) {
      context.read<ProfileController>().saveName(result);
    }
  }

  Future<BigInt?> _openEditNum(
    BuildContext context,
    String title, {
    String? defaultValue,
  }) async {
    final String? result = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return EditModal(
          title: 'Edit $title',
          fieldTitle: 'Amount',
          defaultValue: defaultValue,
          isCurrency: true,
        );
      },
    );

    if (result != null && context.mounted) {
      return BigInt.parse(result);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circleInfo, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Information()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          ProfileCard(
            user: profileController.currentUser,
            isRpg: profileController.isRpg,
            editName: () => _openEditName(
              context,
              defaultValue: profileController.username,
            ),
          ),
          const SizedBox(height: 32),

          AllocationCard(
            livingPercentage: profileController.getAllocation(
              SectorType.living,
            ),
            payDebtPercentage: profileController.getAllocation(
              SectorType.payDebt,
            ),
            emergencyPercentage: profileController.getAllocation(
              SectorType.emergency,
            ),
            investmentPercentage: profileController.getAllocation(
              SectorType.investment,
            ),
            isRpg: profileController.isRpg,
          ),
          const SizedBox(height: 24),

          _buildSettingCard(
            ProfileDict.baseDaily.icon(profileController.isRpg),
            ProfileDict.baseDaily.get(profileController.isRpg),
            '${CurrencyFormatter.convertToIdr(profileController.baseDailyLimit)} / day',
            onTap: () async {
              BigInt? result = await _openEditNum(
                context,
                ProfileDict.baseDaily.get(profileController.isRpg),
                defaultValue: profileController.baseDailyLimit.toString(),
              );
              if (result != null) profileController.saveBaseDailyLimit(result);
            },
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            SkillDict.emergency.icon(profileController.isRpg),
            SkillDict.emergency.get(profileController.isRpg),
            '${CurrencyFormatter.convertToIdr(profileController.emergencyTotal)} / ${CurrencyFormatter.convertToIdr(profileController.emergencyAmount)}',
            currentProgress: profileController.emergencyTotal,
            maxProgress: profileController.emergencyAmount,
            onTap: () async {
              BigInt? result = await _openEditNum(
                context,
                SkillDict.emergency.get(profileController.isRpg),
                defaultValue: profileController.emergencyAmount.toString(),
              );
              if (result != null) profileController.saveEmergencyAmount(result);
            },
          ),
          const SizedBox(height: 32),

          _buildSectionHeader(
            ProfileDict.missions.get(profileController.isRpg),
          ),
          const SizedBox(height: 12),
          _buildTaskItem(
            icon: FontAwesomeIcons.penNib,
            title: profileController.isRpg
                ? 'Daily Combat Log'
                : 'Record Transaction',
            xp: '+10 XP',
            progress: 3,
            max: 5,
            isRpg: profileController.isRpg,
          ),
          _buildTaskItem(
            icon: FontAwesomeIcons.shieldHalved,
            title: profileController.isRpg
                ? 'Castle Defense'
                : 'Daily Budget Cap',
            xp: '+20 XP',
            progress: 1,
            max: 1,
            isRpg: profileController.isRpg,
            subtitle: 'Limit: Rp 50.000 / day',
          ),
          _buildTaskItem(
            icon: FontAwesomeIcons.gem,
            title: profileController.isRpg
                ? 'Treasure Hunt'
                : 'Monthly Savings',
            xp: '+500 XP',
            progress: 0,
            max: 1,
            isRpg: profileController.isRpg,
            isMonthly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    FaIconData icon,
    String title,
    String subtitle, {
    BigInt? currentProgress,
    BigInt? maxProgress,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentProgress != null && maxProgress != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxProgress == BigInt.zero
                            ? 0.0
                            : (currentProgress.toDouble() /
                                      maxProgress.toDouble())
                                  .clamp(0.0, 1.0),
                        backgroundColor: AppColors.background,
                        color: AppColors.primaryDark,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
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
          ],
        ),
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
