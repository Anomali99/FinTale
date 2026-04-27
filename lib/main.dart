import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/mode_provider.dart';
import 'data/local/app_database.dart';
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

  final db = await AppDatabase.instance.database;
  final walletDao = WalletDao(db);
  final assetDao = AssetDao(db);
  final debtDao = DebtDao(db);
  final billDao = BillDao(db);
  final transactionDao = TransactionDao(db);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<ModeProvider>(create: (_) => ModeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthController(authService, prefService, walletDao),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeController(prefService, walletDao, transactionDao),
        ),
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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainLayout();
        }

        return const AuthScreen();
      },
    );
  }
}
