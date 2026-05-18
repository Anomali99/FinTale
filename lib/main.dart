import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/analytics_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/bill_controller.dart';
import 'controllers/history_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/invest_controller.dart';
import 'controllers/layout_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/skill_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/wallet_controller.dart';
import 'core/theme/mode_provider.dart';
import 'data/local/dao/asset_dao.dart';
import 'data/local/dao/bill_dao.dart';
import 'data/local/dao/debt_dao.dart';
import 'data/local/dao/transaction_dao.dart';
import 'data/local/dao/wallet_dao.dart';
import 'data/local/pref_service.dart';
import 'fintale_app.dart';
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
  final layoutController = LayoutController(
    userController,
    walletController,
    transactionController,
  );
  final homeController = HomeController(
    userController,
    walletController,
    transactionController,
  );
  final profileController = ProfileController(userController);
  final skillController = SkillController(userController);
  final billController = BillController(
    billDao,
    debtDao,
    userController,
    transactionController,
  );
  final investController = InvestController(
    assetDao,
    userController,
    walletController,
    transactionController,
  );
  final historyController = HistoryController(transactionController);
  final analyticsController = AnalyticsController(transactionController);
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
        ChangeNotifierProvider(create: (_) => billController),
        ChangeNotifierProvider(create: (_) => investController),
        ChangeNotifierProvider(create: (_) => historyController),
        ChangeNotifierProvider(create: (_) => analyticsController),
        ChangeNotifierProvider(create: (_) => settingsController),
      ],
      child: const FinTaleApp(),
    ),
  );
}
