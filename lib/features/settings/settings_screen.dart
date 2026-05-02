import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/settings_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/menu_dict.dart';
import '../../core/constants/settings_dict.dart';
import '../../widgets/custom_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _handleSignOut(BuildContext context) async {
    final Map<String, dynamic> result = await context
        .read<SettingsController>()
        .handleSignOut();

    if (!context.mounted) return;
    if (result['success']) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: ${result["error"]}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showResetDataWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        title: const Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: AppColors.error,
            ),
            SizedBox(width: 12),
            Text('Reset Data?', style: TextStyle(color: AppColors.error)),
          ],
        ),
        content: const Text(
          'Tindakan ini akan menghapus seluruh riwayat transaksi dan mengulang progress Anda dari awal. Anda yakin ingin melakukan reinkarnasi?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Ya, Reset',
              style: TextStyle(color: Colors.white),
            ),
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
          MenuDict.settings,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        children: [
          _buildSectionHeader(
            SettingsDict.security.get(settingsController.isRpgMode),
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
                  title: const Text('Hide Balance'),
                  subtitle: Text(
                    SettingsDict.balanceDec.get(settingsController.isRpgMode),
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
                  title: const Text('App Lock'),
                  subtitle: const Text('Lock apps with PIN/Biometric'),
                  trailing: Switch(
                    value: settingsController.isAppLock,
                    activeThumbColor: AppColors.primary,
                    onChanged: settingsController.changeAppLock,
                  ),
                ),
              ],
            ),
          ),

          _buildSectionHeader(
            SettingsDict.appSettings.get(settingsController.isRpgMode),
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
                  title: const Text('RPG Terminology'),
                  subtitle: const Text('Immersive adventure mode'),
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
                  title: const Text('Push Notifications'),
                  trailing: Switch(
                    value: settingsController.isNotification,
                    activeThumbColor: AppColors.primary,
                    onChanged: settingsController.changeNotification,
                  ),
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.moon,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  title: const Text('Theme'),
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
            SettingsDict.data.get(settingsController.isRpgMode),
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
                  title: const Text('Export Data (Json)'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    /* TODO: Export Data */
                  },
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.fileArrowUp,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  title: const Text('Import Data'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    /* TODO: Import Data */
                  },
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.trash,
                    color: AppColors.error,
                    size: 20,
                  ),
                  title: const Text(
                    'Reset All Data',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () => _showResetDataWarning(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          CustomButton(
            icon: FontAwesomeIcons.arrowsRotate,
            title: 'Sync to Cloud',
            color: Colors.blueAccent,
            onTap: () {
              /* TODO: Sync Data */
            },
          ),
          const SizedBox(height: 16),
          CustomButton(
            icon: FontAwesomeIcons.arrowRightFromBracket,
            title: 'Sign Out',
            color: AppColors.error,
            onTap: () => _handleSignOut(context),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
