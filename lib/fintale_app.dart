import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/global_messenger.dart';
import 'core/wrappers/auth_wrapper.dart';
import 'core/wrappers/lock_wrapper.dart';
import 'features/analytics/screens/analytics_screen.dart';
import 'features/home/screens/daily_expense_screen.dart';
import 'features/main_layout.dart';
import 'features/profile/screens/info_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/skill_tree_screen.dart';
import 'features/settings/screens/create_pin_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/verify_pin_screen.dart';

class FinTaleApp extends StatelessWidget {
  const FinTaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTale',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: GlobalMessenger.globalMessengerKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) =>
                  AuthWrapper(child: LockWrapper(child: MainLayout())),
            );
          case '/settings':
            return MaterialPageRoute(builder: (_) => SettingsScreen());
          case '/information':
            return MaterialPageRoute(builder: (_) => InfoScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => ProfileScreen());
          case '/skill-tree':
            return MaterialPageRoute(builder: (_) => SkillTreeScreen());
          case '/analytics':
            return MaterialPageRoute(builder: (_) => AnalyticsScreen());
          case '/daily-expense':
            return MaterialPageRoute(builder: (_) => DailyExpenseScreen());
          case '/create-pin':
            return MaterialPageRoute(
              builder: (_) => CreatePinScreen(
                currentPinHash: args?['currentPinHash'],
                userEmail: args?['userEmail'],
              ),
            );
          case '/verify-pin':
            return MaterialPageRoute(
              builder: (_) => VerifyPinScreen(
                savedPinHash: args?['savedPinHash'] ?? '',
                isCancelable: args?['isCancelable'] ?? true,
                isBiometricEnabled: args?['isBiometricEnabled'] ?? false,
                userEmail: args?['userEmail'],
                title: args?['title'],
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
