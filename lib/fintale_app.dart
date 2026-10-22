import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'controllers/analytics_controller.dart';
import 'controllers/bill_controller.dart';
import 'controllers/history_controller.dart';
import 'controllers/invest_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/skill_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/wallet_controller.dart';
import 'core/constants/ui_dict.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/global_messenger.dart';
import 'core/wrappers/auth_wrapper.dart';
import 'core/wrappers/lock_wrapper.dart';
import 'features/analytics/screens/analytics_screen.dart';
import 'features/bills/screens/add_receivable_screen.dart';
import 'features/bills/screens/receivable_detail_screen.dart';
import 'features/home/screens/daily_expense_screen.dart';
import 'features/home/screens/income_screen.dart';
import 'features/invest/screens/buy_asset_screen.dart';
import 'features/main_layout.dart';
import 'features/profile/screens/info_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/skill_tree_screen.dart';
import 'features/settings/screens/create_pin_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/verify_pin_screen.dart';

class FinTaleApp extends StatefulWidget {
  const FinTaleApp({super.key});

  @override
  State<FinTaleApp> createState() => _FinTaleAppState();
}

class _FinTaleAppState extends State<FinTaleApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  static const _importChannel = MethodChannel('id.my.anomali99.fintale/import');

  @override
  void initState() {
    super.initState();
    _importChannel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  void dispose() {
    _importChannel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'importFile') {
      final Uint8List fileBytes = call.arguments as Uint8List;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleIncomingFile(fileBytes);
      });
    }
    return null;
  }

  void _handleIncomingFile(Uint8List fileBytes) {
    final navContext = _navigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;
    _showImportConfirmation(navContext, fileBytes);
  }

  void _showImportConfirmation(BuildContext context, Uint8List fileBytes) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (con) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        title: Row(
          children: [
            Icon(Icons.file_open, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                UiDict.setImport,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          UiDict.setImportDesc,
          style: TextStyle(color: colorScheme.onSurface),
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
              Navigator.pop(con);
              _executeIntentImport(context, fileBytes);
            },
            child: Text(
              UiDict.setImportBtn,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  void _executeIntentImport(BuildContext context, Uint8List fileBytes) async {
    final colorScheme = Theme.of(context).colorScheme;
    final settingsController = context.read<SettingsController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
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
      ),
    );

    final result = await settingsController.handleImportFromIntent(fileBytes);

    if (!context.mounted) return;
    Navigator.pop(context);

    if (result['need_password'] == true) {
      final Uint8List? cachedBytes = result['file_bytes'] as Uint8List?;
      _showIntentPasswordDialog(
        context,
        fileBytes: cachedBytes ?? fileBytes,
        isWrongPassword: result['wrong_password'] == true,
      );
      return;
    }

    if (result['success'] == true) {
      await _reloadAllControllers(context);
      if (!context.mounted) return;
      GlobalMessenger.showMessage(
        context,
        message: UiDict.setSuccessImport,
        isSuccess: true,
      );
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    } else {
      if (!context.mounted) return;
      final error = result['error'] as String?;
      GlobalMessenger.showMessage(
        context,
        message: error ?? UiDict.setFailedImport,
        isSuccess: false,
      );
    }
  }

  void _showIntentPasswordDialog(
    BuildContext context, {
    required Uint8List fileBytes,
    bool isWrongPassword = false,
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
        _executeIntentImportWithPassword(context, fileBytes, password);
      }
    });
  }

  void _executeIntentImportWithPassword(
    BuildContext context,
    Uint8List fileBytes,
    String password,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final settingsController = context.read<SettingsController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
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
      ),
    );

    final result = await settingsController.handleImportWithPassword(
      fileBytes: fileBytes,
      password: password,
    );

    if (!context.mounted) return;
    Navigator.pop(context);

    if (result['need_password'] == true) {
      final Uint8List? cachedBytes = result['file_bytes'] as Uint8List?;
      _showIntentPasswordDialog(
        context,
        fileBytes: cachedBytes ?? fileBytes,
        isWrongPassword: result['wrong_password'] == true,
      );
      return;
    }

    if (result['success'] == true) {
      await _reloadAllControllers(context);
      if (!context.mounted) return;
      GlobalMessenger.showMessage(
        context,
        message: UiDict.setSuccessImport,
        isSuccess: true,
      );
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    } else {
      if (!context.mounted) return;
      final error = result['error'] as String?;
      GlobalMessenger.showMessage(
        context,
        message: error ?? UiDict.setFailedImport,
        isSuccess: false,
      );
    }
  }

  Future<void> _reloadAllControllers(BuildContext context) async {
    if (!context.mounted) return;
    final walletController = context.read<WalletController>();
    final userController = context.read<UserController>();
    final transactionController = context.read<TransactionController>();
    final skillController = context.read<SkillController>();
    final billController = context.read<BillController>();
    final investController = context.read<InvestController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();

    await walletController.loadData();
    await userController.loadData();
    await transactionController.loadData();
    await skillController.loadData();
    await billController.loadData();
    await investController.loadData();
    await historyController.applyFilter();
    await analyticsController.applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    return MaterialApp(
      title: 'FinTale',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsController.themeMode,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: GlobalMessenger.globalMessengerKey,
      navigatorKey: _navigatorKey,
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
          case '/income-record':
            return MaterialPageRoute(
              builder: (_) => IncomeScreen(
                isTransfer: args?['isTransfer'],
                allocation: args?['allocation'],
              ),
            );
          case '/add-receivable':
            return MaterialPageRoute(
              builder: (_) => AddReceivableScreen(
                existingNames: args?['existingNames'] ?? [],
                initialReceivable: args?['initialReceivable'],
              ),
            );
          case '/receivable-detail':
            return MaterialPageRoute(
              builder: (_) => ReceivableDetailScreen(
                borrowerName: args?['borrowerName'] ?? '',
                initialRecords: args?['initialRecords'] ?? [],
              ),
            );
          case '/buy-asset':
            return MaterialPageRoute(
              builder: (_) => BuyAssetScreen(
                assets: args?['assets'] ?? [],
                wallets: args?['wallets'] ?? [],
                initialAsset: args?['initialAsset'],
                initialRisk: args?['initialRisk'],
                pendingAllocation: args?['pendingAllocation'],
                isEmergency: args?['isEmergency'] ?? false,
              ),
            );
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
