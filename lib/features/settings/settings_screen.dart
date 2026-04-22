import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/settings_dict.dart';
import '../../core/dummy/dummy_data.dart';
import '../../core/theme/mode_provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import 'widgets/profil_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserModel user = DummyData.user;
  bool _isNotificationsEnabled = true;
  String _selectedTheme = 'Dark';
  int _activeStrategyLevel = 5;

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
          content: Text('Koneksi gagal: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: user.name,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() => nameController.text);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showStrategySelector(bool isRpg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Select ${SettingsDict.allocationRules.get(isRpg)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: user.level,
                  itemBuilder: (context, index) {
                    int levelStr = index + 1;
                    bool isSelected = levelStr == _activeStrategyLevel;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.surfaceVariant,
                        child: Text(
                          'L$levelStr',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Level $levelStr Strategy',
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        isRpg
                            ? 'Change allocation tactic'
                            : 'Change distribution rule',
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() => _activeStrategyLevel = levelStr);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
        padding: const EdgeInsets.all(24.0),
        children: [
          ProfilCard(user: user, isRpg: isRpg, editName: _showEditNameDialog),

          const SizedBox(height: 32),

          Text(
            SettingsDict.allocationRules.get(isRpg),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.chessKnight,
                  color: AppColors.warning,
                ),
              ),
              title: Text('Level $_activeStrategyLevel Strategy'),
              subtitle: Text(
                'Needs: 50% | Debt: 25% | Assets: 25%',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () => _showStrategySelector(isRpg),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            SettingsDict.appSettings.get(isRpg),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
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
                    onChanged: (value) {
                      modeProvider.toggleMode();
                    },
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
                  subtitle: Text(SettingsDict.notifDec.get(isRpg)),
                  trailing: Switch(
                    value: _isNotificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() => _isNotificationsEnabled = value);
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
                      if (newValue != null) {
                        setState(() => _selectedTheme = newValue);
                      }
                    },
                    items: <String>['Dark'].map<DropdownMenuItem<String>>((
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
          const SizedBox(height: 32),

          CustomButton(
            icon: FontAwesomeIcons.arrowsRotate,
            title: 'Sync',
            color: Colors.blueAccent,
            onTap: () => {
              /* TODO: Sync */
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
