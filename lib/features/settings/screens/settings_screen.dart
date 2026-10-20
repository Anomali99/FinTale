import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/color_extension.dart';
import '../../../core/utils/global_messenger.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/responsive_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final settingsController = context.read<SettingsController>();
    _passwordController = TextEditingController(
      text: settingsController.backupCustomPassword ?? '',
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAction(
    BuildContext context,
    Function onAction, {
    String? onSuccess,
    String? onFailed,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          ),
        );
      },
    );

    final Map<String, dynamic> result = await onAction();

    if (!context.mounted) return;

    Navigator.pop(context);

    if (result['need_password'] == true) {
      // Pass the cached file bytes so the retry doesn't open the picker again
      final Uint8List? cachedBytes = result['file_bytes'] as Uint8List?;
      _showPasswordDialog(
        context,
        isWrongPassword: result['wrong_password'] == true,
        fileBytes: cachedBytes,
      );
      return;
    }

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
        await historyController.applyFilter();
        await analyticsController.applyFilter();
      }

      if (!context.mounted) return;

      if (onSuccess != null) {
        GlobalMessenger.showMessage(
          context,
          message: onSuccess,
          isSuccess: true,
        );
      }
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      if (!context.mounted) return;
      String? failed = onFailed ?? result["error"];
      if (failed != null) {
        GlobalMessenger.showMessage(context, message: failed, isSuccess: false);
      }
    }
  }

  void _showPasswordDialog(
    BuildContext context, {
    bool isWrongPassword = false,
    Uint8List? fileBytes,
  }) {
    final controller = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (con) => StatefulBuilder(
        builder: (context, setDialogState) {
          final colorScheme = Theme.of(context).colorScheme;
          return AlertDialog(
            backgroundColor: colorScheme.surfaceContainerHighest,
            title: Text(UiDict.setPasswordInput),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWrongPassword)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      UiDict.setPasswordWrong,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ),
                Text(
                  UiDict.setPasswordRequired,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: UiDict.setBackupPassword,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(con),
                child: Text(
                  UiDict.cancel,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.pop(con, controller.text);
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            ],
          );
        },
      ),
    ).then((password) {
      if (password != null && password.isNotEmpty && context.mounted) {
        final settingsController = context.read<SettingsController>();
        if (fileBytes != null) {
          // Retry decrypt with the cached file bytes — no picker reopened
          _handleAction(
            context,
            () => settingsController.handleImportWithPassword(
              fileBytes: fileBytes,
              password: password,
            ),
            onSuccess: UiDict.setSuccessImport,
            onFailed: UiDict.setFailedImport,
          );
        } else {
          // Fallback: re-pick file (shouldn't happen in normal flow)
          _handleAction(
            context,
            () => settingsController.handleImportData(),
            onSuccess: UiDict.setSuccessImport,
            onFailed: UiDict.setFailedImport,
          );
        }
      }
    });
  }

  void _showWarningDialog(
    BuildContext context, {
    required String title,
    required String desc,
    required VoidCallback onYes,
    String yesTitle = 'Yes',
    bool isDanger = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (con) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        title: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: isDanger
                  ? colorScheme.error
                  : AppColors.getWarning(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDanger
                      ? colorScheme.error
                      : AppColors.getWarning(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(desc, style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(con),
            child: Text(
              UiDict.cancel,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger
                  ? colorScheme.error
                  : AppColors.getWarning(context),
            ),
            onPressed: () {
              Navigator.pop(con);
              onYes();
            },
            child: Text(
              yesTitle,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 24.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = context
        .watch<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UiDict.settings,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ResponsiveContainer(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          children: [
            _buildSectionHeader(
              UiDict.setSecurityGroup.get(settingsController.isRpgMode),
              colorScheme.primary,
            ),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.eyeSlash,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(UiDict.setHideBalance),
                    subtitle: Text(
                      UiDict.setBalanceDesc.get(settingsController.isRpgMode),
                    ),
                    trailing: Switch(
                      value: settingsController.isHideBalance,
                      activeThumbColor: colorScheme.primary,
                      onChanged: settingsController.changeHideBalance,
                    ),
                  ),
                  Divider(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 1,
                    indent: 56,
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.lock,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(UiDict.setAppLock),
                    subtitle: const Text(UiDict.setLockDesc),
                    trailing: Switch(
                      value: settingsController.isAppLock,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) async {
                        bool success = await settingsController.changeAppLock(
                          context,
                          val,
                        );
                        if (!success && context.mounted) {
                          GlobalMessenger.showMessage(
                            context,
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
                        color: colorScheme.onPrimary.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Divider(
                            color: colorScheme.onSurface.withValues(alpha: 0.1),
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
                            trailing: Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onTap: () async {
                              bool success = await settingsController
                                  .handleResetPin(context);
                              if (context.mounted) {
                                GlobalMessenger.showMessage(
                                  context,
                                  message: success
                                      ? UiDict.changePinSuccess
                                      : UiDict.changePinCancel,
                                  isSuccess: success,
                                );
                              }
                            },
                          ),

                          if (settingsController
                              .isHardwareBiometricSupported) ...[
                            Divider(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.1,
                              ),
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
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              value: settingsController.isBiometricActive,
                              activeThumbColor: colorScheme.primary,
                              onChanged: (val) async {
                                bool success = await settingsController
                                    .changeBiometric(context, val);
                                if (!success && context.mounted) {
                                  GlobalMessenger.showMessage(
                                    context,
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
              colorScheme.primary,
            ),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.khanda,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(UiDict.setRpg),
                    subtitle: const Text(UiDict.setRpgDesc),
                    trailing: Switch(
                      value: settingsController.isRpgMode,
                      activeThumbColor: colorScheme.primary,
                      onChanged: settingsController.changeRpgMode,
                    ),
                  ),
                  Divider(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 1,
                    indent: 56,
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.piggyBank,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: const Text('Kecualikan Tabungan'),
                    subtitle: const Text(
                      'Kecualikan saldo tabungan dari total saldo di beranda dan detail dompet',
                    ),
                    trailing: Switch(
                      value: !settingsController.isIncludeSavingsInTotal,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) =>
                          settingsController.changeIncludeSavingsInTotal(!val),
                    ),
                  ),
                  Divider(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 1,
                    indent: 56,
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.bell,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(UiDict.setNotification),
                    trailing: Switch(
                      value: settingsController.isNotification,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) async {
                        bool success = await settingsController
                            .changeNotification(context, val);
                        if (context.mounted) {
                          if (!success) {
                            GlobalMessenger.showMessage(
                              context,
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
                  Divider(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 1,
                    indent: 56,
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.paintbrush,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(UiDict.setTheme),
                    trailing: DropdownButton<ThemeMode>(
                      value: settingsController.themeMode,
                      underline: const SizedBox(),
                      dropdownColor: colorScheme.surfaceContainerHighest,
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                      ],
                      onChanged: settingsController.changeThemeMode,
                    ),
                  ),
                  Divider(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 1,
                    indent: 56,
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.scaleBalanced,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: const Text('Lisensi Sumber Terbuka'),
                    subtitle: const Text('Lisensi dan atribusi pustaka'),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'FinTale',
                        applicationVersion: settingsController.appVersion,
                        applicationLegalese:
                            '© 2026 FinTale. All rights reserved.',
                      );
                    },
                  ),
                ],
              ),
            ),

            _buildSectionHeader(
              UiDict.setDataGroup.get(settingsController.isRpgMode),
              colorScheme.primary,
            ),

            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Backup Encryption toggle
                  SwitchListTile(
                    secondary: FaIcon(
                      FontAwesomeIcons.shieldHalved,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(UiDict.setBackupEncryption),
                    subtitle: Text(UiDict.setBackupEncryptionDesc),
                    value: settingsController.isBackupEncryption,
                    activeThumbColor: colorScheme.primary,
                    onChanged: (val) =>
                        settingsController.changeBackupEncryption(val),
                  ),
                  if (settingsController.isBackupEncryption) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withValues(alpha: 0.1),
                      ),
                      child: Column(
                        children: [
                          Divider(
                            color: colorScheme.onSurface.withValues(alpha: 0.1),
                            height: 1,
                            indent: 56,
                          ),
                          SwitchListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 56,
                              right: 16,
                            ),
                            title: Text(
                              UiDict.setBackupUseCustom,
                              style: TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              UiDict.setBackupUseCustomDesc,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            value: settingsController.isBackupUseCustom,
                            activeThumbColor: colorScheme.primary,
                            onChanged: (val) =>
                                settingsController.changeBackupUseCustom(val),
                          ),
                          if (settingsController.isBackupUseCustom) ...[
                            Divider(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.1,
                              ),
                              height: 1,
                              indent: 56,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 56,
                                right: 16,
                                top: 8,
                                bottom: 12,
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: UiDict.setBackupPassword,
                                  hintText: UiDict.setBackupPasswordHint,
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  settingsController.changeBackupCustomPassword(
                                    value,
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  Divider(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 1,
                    indent: 56,
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.fileArrowDown,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(UiDict.setExport),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onTap: () async {
                      bool success = await settingsController
                          .handleExportData();
                      if (context.mounted) {
                        GlobalMessenger.showMessage(
                          context,
                          message: success
                              ? UiDict.setSuccessExport
                              : UiDict.setFailedExport,
                          isSuccess: success,
                        );
                      }
                    },
                  ),
                  Divider(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 1,
                    indent: 56,
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.fileArrowUp,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(UiDict.setImport),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onTap: () => _showWarningDialog(
                      context,
                      title: UiDict.setWarning,
                      desc: UiDict.setImportDesc,
                      yesTitle: UiDict.setImportBtn,
                      onYes: () => _handleAction(
                        context,
                        settingsController.handleImportData,
                        onSuccess: UiDict.setSuccessImport,
                        onFailed: UiDict.setFailedImport,
                      ),
                    ),
                  ),
                  Divider(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 1,
                    indent: 56,
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.trash,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    title: Text(
                      UiDict.setDataReset,
                      style: TextStyle(color: colorScheme.error),
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
              icon: FontAwesomeIcons.upload,
              title: 'Backup ke Cloud',
              color: Colors.greenAccent.adapt(context),
              onTap: () async {
                bool success = await settingsController.handleBackupData();
                if (context.mounted) {
                  GlobalMessenger.showMessage(
                    context,
                    message: success
                        ? UiDict.setSuccessExport
                        : UiDict.setFailedExport,
                    isSuccess: success,
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              icon: FontAwesomeIcons.download,
              title: 'Restore dari Cloud',
              color: Colors.blueAccent.adapt(context),
              onTap: () => _showWarningDialog(
                context,
                title: UiDict.setWarning,
                desc: UiDict.setImportDesc,
                yesTitle: UiDict.setImportBtn,
                onYes: () => _handleAction(
                  context,
                  settingsController.handleRestoreData,
                  onSuccess: UiDict.setSuccessImport,
                  onFailed: UiDict.setFailedImport,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              icon: FontAwesomeIcons.arrowRightFromBracket,
              title: UiDict.setSignOut,
              color: colorScheme.error,
              onTap: () => _showWarningDialog(
                context,
                title: UiDict.setWarning,
                desc: UiDict.setLogOutDesc,
                yesTitle: UiDict.setLogOutBtn,
                onYes: () =>
                    _handleAction(context, settingsController.handleSignOut),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'FinTale',
                    applicationVersion: '1.1.0',
                    applicationLegalese: '© 2026 FinTale. All rights reserved.',
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    'FinTale ${settingsController.appVersion}  •  Created by Anomali99',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
