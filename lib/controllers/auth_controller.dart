import 'package:flutter/material.dart';

import '../data/local/app_database.dart';
import '../data/local/dao/wallet_dao.dart';
import '../data/local/pref_service.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService;
  final PrefService _prefService;
  final WalletDao _walletDao;

  bool isLoading = false;
  String? errorMessage;

  AuthController(this._authService, this._prefService, this._walletDao);

  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential.user != null) {
        await _setupNewUser(
          userCredential.user!.uid,
          userCredential.user!.email ?? '',
          userCredential.user!.displayName ?? 'Petualang',
        );
      }
    } catch (e) {
      errorMessage = 'Koneksi gagal: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginAnonymously() async {
    _setLoading(true);
    try {
      final userCredential = await _authService.signInAnonymously();
      if (userCredential.user != null) {
        await _setupNewUser(userCredential.user!.uid, null, 'Anonymous');
      }
    } catch (e) {
      errorMessage = 'Gagal masuk mode lokal: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _setupNewUser(String uid, String? email, String name) async {
    UserModel? existingUser = _prefService.getUser();

    if (existingUser == null) {
      UserModel newUser = UserModel(
        uid: uid,
        name: name.isEmpty ? 'Petualang Anonim' : name,
        email: email,
        title: TitleType.noviceSaver,
        level: 1,
        xp: 0,
        baseDailyLimit: BigInt.parse('50000'),
        dailyPenalty: BigInt.zero,
        todayUsage: BigInt.zero,
        lastActiveDate: DateTime.now().microsecondsSinceEpoch,
        emergencyAmount: BigInt.zero,
        emergencyTotal: BigInt.zero,
        skillAllocations: {},
      );
      await _prefService.saveUser(newUser);

      WalletModel defaultWallet = WalletModel(
        name: 'Cash',
        type: WalletType.cash,
        amount: BigInt.zero,
      );
      await _walletDao.create(defaultWallet);
    }
  }

  Future<void> logoutAndClearData() async {
    await _authService.signOut();
    await _prefService.clearAll();
    await AppDatabase.instance.deleteDB();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
