import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/profile_controller.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/profile_dict.dart';
import '../../core/constants/skill_dict.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/allocation_model.dart';
import 'widgets/allocation_card.dart';
import 'widgets/daily_missions.dart';
import 'widgets/edit_modal.dart';
import 'widgets/information.dart';
import 'widgets/profile_card.dart';
import 'widgets/skill_tree.dart';

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
    final userController = context.watch<UserController>();

    final isRpg = userController.isRpgMode;
    final currentUser = userController.currentUser;
    final userName = userController.userName;
    final baseDailyLimit = userController.baseDailyLimit;
    final emergencyTotal = userController.emergencyTotal;
    final emergencyAmount = userController.emergencyAmount;
    final progress = userController.progress;

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
            user: currentUser,
            isRpg: isRpg,
            editName: () => _openEditName(context, defaultValue: userName),
          ),
          const SizedBox(height: 32),

          AllocationCard(
            livingPercentage: userController.getAllocation(SectorType.living),
            payDebtPercentage: userController.getAllocation(SectorType.payDebt),
            emergencyPercentage: userController.getAllocation(
              SectorType.emergency,
            ),
            investmentPercentage: userController.getAllocation(
              SectorType.investment,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SkillTree()),
            ),
            isRpg: isRpg,
          ),
          const SizedBox(height: 24),

          _buildSettingCard(
            ProfileDict.baseDaily.icon(isRpg),
            ProfileDict.baseDaily.get(isRpg),
            '${CurrencyFormatter.convertToIdr(baseDailyLimit)} / day',
            onTap: () async {
              BigInt? result = await _openEditNum(
                context,
                ProfileDict.baseDaily.get(isRpg),
                defaultValue: baseDailyLimit.toString(),
              );
              if (result != null) profileController.saveBaseDailyLimit(result);
            },
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            SkillDict.emergency.icon(isRpg),
            SkillDict.emergency.get(isRpg),
            '${CurrencyFormatter.convertToIdr(emergencyTotal)} / ${CurrencyFormatter.convertToIdr(emergencyAmount)}',
            currentProgress: emergencyTotal,
            maxProgress: emergencyAmount,
            onTap: () async {
              BigInt? result = await _openEditNum(
                context,
                SkillDict.emergency.get(isRpg),
                defaultValue: emergencyAmount.toString(),
              );
              if (result != null) profileController.saveEmergencyAmount(result);
            },
          ),
          const SizedBox(height: 32),
          ...[
            _buildSectionHeader(ProfileDict.missions.get(isRpg)),
            const SizedBox(height: 12),
            DailyMissions(progress: progress),
          ],
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
}
