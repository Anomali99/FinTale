import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/analytics_controller.dart';
import '../../../controllers/bill_controller.dart';
import '../../../controllers/history_controller.dart';
import '../../../controllers/invest_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/skill_controller.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/global_messenger.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _handleAction(
    BuildContext context,
    Function onAction, {
    String? onSuccess,
    String? onFailed,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: AppColors.surfaceVariant,
            content: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      },
    );

    final Map<String, dynamic> result = await onAction();

    if (!context.mounted) return;

    Navigator.pop(context);

    if (result['success']) {
      WalletModel? wallet = result['wallet'];
      if (wallet != null || result['load'] == true) {
        final walletController = context.read<WalletController>();
        final userController = context.read<UserController>();
        final transactionController = context.read<TransactionController>();
        final skillController = context.read<SkillController>();
        final billController = context.read<BillController>();
        final investController = context.read<InvestController>();
        final historyController = context.read<HistoryController>();
        final analyticsController = context.read<AnalyticsController>();

        if (wallet != null) {
          await walletController.createWallet(wallet);
        }
        await walletController.loadData();
        await userController.loadData();
        await transactionController.loadData();
        await skillController.loadData();
        await billController.loadData();
        await investController.loadData();
        historyController.applyFilter();
        analyticsController.applyFilter();
      }

      if (onSuccess != null) {
        GlobalMessenger.swowMessage(message: onSuccess, isSuccess: true);
      }
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      String? failed = onFailed ?? result["error"];
      if (failed != null) {
        GlobalMessenger.swowMessage(message: failed, isSuccess: false);
      }
    }
  }

  void _showWarningDialog(
    BuildContext context, {
    required String title,
    required String desc,
    required VoidCallback onYes,
    String yesTitle = 'Yes',
    bool isDanger = true,
  }) {
    showDialog(
      context: context,
      builder: (con) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        title: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: isDanger ? AppColors.error : AppColors.warning,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDanger ? AppColors.error : AppColors.warning,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          desc,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(con),
            child: Text(
              UiDict.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? AppColors.error : AppColors.warning,
            ),
            onPressed: () {
              Navigator.pop(con);
              onYes();
            },
            child: Text(yesTitle, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 24.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = context
        .watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UiDict.settings,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        children: [
          _buildSectionHeader(
            UiDict.setSecurityGroup.get(settingsController.isRpgMode),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.eyeSlash,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  title: Text(UiDict.setHideBalance),
                  subtitle: Text(
                    UiDict.setBalanceDesc.get(settingsController.isRpgMode),
                  ),
                  trailing: Switch(
                    value: settingsController.isHideBalance,
                    activeThumbColor: AppColors.primary,
                    onChanged: settingsController.changeHideBalance,
                  ),
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.lock,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  title: Text(UiDict.setAppLock),
                  subtitle: const Text(UiDict.setLockDesc),
                  trailing: Switch(
                    value: settingsController.isAppLock,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) async {
                      bool success = await settingsController.changeAppLock(
                        context,
                        val,
                      );
                      if (!success && context.mounted) {
                        GlobalMessenger.swowMessage(
                          message: UiDict.authRequired,
                          isSuccess: false,
                        );
                      }
                    },
                  ),
                ),
                if (settingsController.isAppLock) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Divider(
                          color: Colors.white10,
                          height: 1,
                          indent: 56,
                        ),

                        ListTile(
                          contentPadding: const EdgeInsets.only(
                            left: 56,
                            right: 16,
                          ),
                          title: Text(
                            UiDict.changePin,
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () async {
                            bool success = await settingsController
                                .handleResetPin(context);
                            if (!success && context.mounted) {
                              GlobalMessenger.swowMessage(
                                message: UiDict.changePinCancel,
                                isSuccess: false,
                              );
                            }
                          },
                        ),

                        if (settingsController
                            .isHardwareBiometricSupported) ...[
                          const Divider(
                            color: Colors.white10,
                            height: 1,
                            indent: 56,
                          ),
                          SwitchListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 56,
                              right: 16,
                            ),
                            title: Text(
                              UiDict.biometric,
                              style: TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              UiDict.biometricDesc,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            value: settingsController.isBiometricActive,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) async {
                              bool success = await settingsController
                                  .changeBiometric(context, val);
                              if (!success && context.mounted) {
                                GlobalMessenger.swowMessage(
                                  message: UiDict.biometricFailed,
                                  isSuccess: false,
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          _buildSectionHeader(
            UiDict.setAppGroup.get(settingsController.isRpgMode),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.khanda,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  title: Text(UiDict.setRpg),
                  subtitle: const Text(UiDict.setRpgDesc),
                  trailing: Switch(
                    value: settingsController.isRpgMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: settingsController.changeRpgMode,
                  ),
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.bell,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  title: Text(UiDict.setNotification),
                  trailing: Switch(
                    value: settingsController.isNotification,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) async {
                      bool success = await settingsController
                          .changeNotification(context, val);
                      if (context.mounted) {
                        if (!success) {
                          GlobalMessenger.swowMessage(
                            message: UiDict.setNotificationsFiled,
                            isSuccess: false,
                          );
                        } else {
                          if (val) {
                            await context
                                .read<BillController>()
                                .checAndCreateNotification();
                          }
                        }
                      }
                    },
                  ),
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.moon,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  title: Text(UiDict.setTheme),
                  trailing: DropdownButton<String>(
                    value: settingsController.themeMode,
                    dropdownColor: AppColors.surface,
                    underline: const SizedBox(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textSecondary,
                    ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    onChanged: settingsController.changeThemeMode,
                    items: <String>['Dark', 'Light', 'System'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value.toLowerCase(),
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          _buildSectionHeader(
            UiDict.setDataGroup.get(settingsController.isRpgMode),
          ),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.fileArrowDown,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  title: Text(UiDict.setExport),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () async {
                    bool success = await settingsController.handleExportData();
                    if (context.mounted) {
                      GlobalMessenger.swowMessage(
                        message: success
                            ? 'Catatan petualangan berhasil dikemas!'
                            : 'Gagal mengekstrak data!',
                        isSuccess: success,
                      );
                    }
                  },
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.fileArrowUp,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  title: Text(UiDict.setImport),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => _showWarningDialog(
                    context,
                    title: 'Peringatan Migrasi Data!',
                    desc:
                        'Melakukan import akan menghapus seluruh data Anda saat ini dan menimpanya dengan data dari file JSON. Lanjutkan?',
                    yesTitle: 'Ya, Timpa Data',
                    onYes: () => _handleAction(
                      context,
                      settingsController.handleImportData,
                      onSuccess:
                          'Harta dan catatan petualangan berhasil dipulihkan!',
                      onFailed: 'Struktur file JSON rusak atau tidak valid!',
                    ),
                  ),
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.trash,
                    color: AppColors.error,
                    size: 20,
                  ),
                  title: Text(
                    UiDict.setDataReset,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  onTap: () => _showWarningDialog(
                    context,
                    title: '${UiDict.setDataReset}?',
                    desc: UiDict.setDataResetDesc,
                    yesTitle: UiDict.setDataResetBtn,
                    onYes: () => _handleAction(
                      context,
                      settingsController.handleResetData,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          CustomButton(
            icon: FontAwesomeIcons.arrowsRotate,
            title: UiDict.setSync,
            color: Colors.blueAccent,
            onTap: () {
              /* TODO: Sync Data */
            },
          ),
          const SizedBox(height: 16),
          CustomButton(
            icon: FontAwesomeIcons.arrowRightFromBracket,
            title: UiDict.setSignOut,
            color: AppColors.error,
            onTap: () =>
                _handleAction(context, settingsController.handleSignOut),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
