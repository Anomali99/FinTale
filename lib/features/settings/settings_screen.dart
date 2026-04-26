import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/settings_dict.dart';
import '../../core/theme/mode_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationsEnabled = true;
  bool _isHideBalanceEnabled = false;
  bool _isAppLockEnabled = false;
  String _selectedTheme = 'Dark';

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();

      if (!context.mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showResetDataWarning() {
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
    final modeProvider = Provider.of<ModeProvider>(context);
    final isRpg = modeProvider.isRpgMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        children: [
          _buildSectionHeader(SettingsDict.security.get(isRpg)),
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
                  subtitle: Text(SettingsDict.balanceDec.get(isRpg)),
                  trailing: Switch(
                    value: _isHideBalanceEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) =>
                        setState(() => _isHideBalanceEnabled = value),
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
                    value: _isAppLockEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) =>
                        setState(() => _isAppLockEnabled = value),
                  ),
                ),
              ],
            ),
          ),

          _buildSectionHeader(SettingsDict.appSettings.get(isRpg)),
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
                    value: isRpg,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) => modeProvider.toggleMode(),
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
                    value: _isNotificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) =>
                        setState(() => _isNotificationsEnabled = value),
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
                    value: _selectedTheme,
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
                    onChanged: (String? newValue) {
                      if (newValue != null)
                        setState(() => _selectedTheme = newValue);
                    },
                    items: <String>['Dark', 'Light', 'System'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          _buildSectionHeader(SettingsDict.data.get(isRpg)),
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
                  onTap: _showResetDataWarning,
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
