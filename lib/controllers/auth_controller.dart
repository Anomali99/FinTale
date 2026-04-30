import 'package:flutter/material.dart';

import '../core/utils/starter_pack.dart';
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
        final user = userCredential.user!;
        await _setupNewUser(user.uid, user.email ?? '', user.displayName ?? '');
      }
    } catch (e) {
      errorMessage = '[AUTH] Connection failed: $e';
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
      errorMessage = '[AUTH] Failed to enter local mode: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _setupNewUser(String uid, String? email, String name) async {
    UserModel? existingUser = _prefService.getUser();

    if (existingUser == null) {
      UserModel newUser = StarterPack.generateUser(
        uid: uid,
        name: name,
        email: email,
      );
      await _prefService.saveUser(newUser);

      WalletModel defaultWallet = StarterPack.defaultWallet;
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
