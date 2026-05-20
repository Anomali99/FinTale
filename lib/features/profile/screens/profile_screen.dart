import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/gamification_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/enum_types.dart';
import '../widgets/allocation_card.dart';
import '../widgets/daily_missions.dart';
import '../widgets/edit_modal.dart';
import '../widgets/profile_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openEditName(BuildContext context, {String? defaultValue}) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditModal(
        title: UiDict.getEdit(UiDict.name),
        fieldTitle: UiDict.name,
        defaultValue: defaultValue,
      ),
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
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditModal(
        title: UiDict.getEdit(title),
        fieldTitle: UiDict.amount,
        defaultValue: defaultValue,
        isCurrency: true,
      ),
    );

    if (result != null && context.mounted) {
      return BigInt.parse(result);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final profileController = context.watch<ProfileController>();
    final userController = context.watch<UserController>();

    final isRpg = settingsController.isRpgMode;
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
          UiDict.profile,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circleInfo, size: 20),
            onPressed: () => Navigator.pushNamed(context, '/information'),
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
            onTap: () => Navigator.pushNamed(context, '/skill-tree'),
            isRpg: isRpg,
          ),
          const SizedBox(height: 24),

          _buildSettingCard(
            ScreenDict.homeDailyLimit.icon(isRpg),
            ScreenDict.homeDailyLimit.get(isRpg),
            '${CurrencyFormatter.convertToIdr(baseDailyLimit)} / day',
            onTap: () async {
              BigInt? result = await _openEditNum(
                context,
                ScreenDict.homeDailyLimit.get(isRpg),
                defaultValue: baseDailyLimit.toString(),
              );
              if (result != null) profileController.saveBaseDailyLimit(result);
            },
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            GamificationDict.skillEmergency.icon(isRpg),
            GamificationDict.skillEmergency.get(isRpg),
            '${CurrencyFormatter.convertToIdr(emergencyTotal)} / ${CurrencyFormatter.convertToIdr(emergencyAmount)}',
            currentProgress: emergencyTotal,
            maxProgress: emergencyAmount,
            onTap: () async {
              BigInt? result = await _openEditNum(
                context,
                GamificationDict.skillEmergency.get(isRpg),
                defaultValue: emergencyAmount.toString(),
              );
              if (result != null) profileController.saveEmergencyAmount(result);
            },
          ),
          const SizedBox(height: 32),
          DailyMissions(progress: progress, isRpg: isRpg),
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
}
