import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/auth_controller.dart';
import 'controllers/history_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/layout_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/skill_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/wallet_controller.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/mode_provider.dart';
import 'core/utils/global_messenger.dart';
import 'data/local/dao/asset_dao.dart';
import 'data/local/dao/bill_dao.dart';
import 'data/local/dao/debt_dao.dart';
import 'data/local/dao/transaction_dao.dart';
import 'data/local/dao/wallet_dao.dart';
import 'data/local/pref_service.dart';
import 'features/auth/auth_screen.dart';
import 'features/main_layout.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final prefService = PrefService(prefs);
  final authService = AuthService();

  final walletDao = WalletDao();
  final assetDao = AssetDao();
  final debtDao = DebtDao();
  final billDao = BillDao();
  final transactionDao = TransactionDao();

  final userController = UserController(prefService);
  final walletController = WalletController(walletDao);
  final transactionController = TransactionController(transactionDao);
  final authController = AuthController(
    authService,
    userController,
    walletController,
  );
  final layoutController = LayoutController(prefService);
  final homeController = HomeController(
    userController,
    walletController,
    transactionController,
  );
  final profileController = ProfileController(userController);
  final skillController = SkillController(userController);
  final historyController = HistoryController(transactionController);
  final settingsController = SettingsController(prefService, authController);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<ModeProvider>(create: (_) => ModeProvider()),
        ChangeNotifierProvider(create: (_) => userController),
        ChangeNotifierProvider(create: (_) => walletController),
        ChangeNotifierProvider(create: (_) => transactionController),
        ChangeNotifierProvider(create: (_) => authController),
        ChangeNotifierProvider(create: (_) => layoutController),
        ChangeNotifierProvider(create: (_) => homeController),
        ChangeNotifierProvider(create: (_) => profileController),
        ChangeNotifierProvider(create: (_) => skillController),
        ChangeNotifierProvider(create: (_) => historyController),
        ChangeNotifierProvider(create: (_) => settingsController),
      ],
      child: const FinTaleApp(),
    ),
  );
}

class FinTaleApp extends StatelessWidget {
  const FinTaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTale',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: GlobalMessenger.globalMessengerKey,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final authController = context.watch<AuthController>();

    return StreamBuilder(
      stream: authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          if (authController.isLoading) {
            return Scaffold(
              backgroundColor: AppColors.surface,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Setting up your character profile...',
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return MainLayout();
        }

        return const AuthScreen();
      },
    );
  }
}
