import 'package:flutter/material.dart';

import '../core/utils/starter_pack.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import 'user_controller.dart';
import 'wallet_controller.dart';

class AuthController with ChangeNotifier {
  final UserController _userController;
  final WalletController _walletController;

  bool isLoading = false;
  String? errorMessage;

  AuthController(this._userController, this._walletController);

  Future<void> loginAnonymously() async {
    _setLoading(true);
    try {
      final String localUid = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      await _setupNewUser(localUid);
    } catch (e) {
      errorMessage = '[AUTH] Failed to enter local mode: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _setupNewUser(String uid, {String? email, String? name}) async {
    await _userController.loadData();
    await _walletController.loadData();
    final user = _userController.currentUser;
    final wallet = _walletController.wallets;
    if (user == null) {
      UserModel newUser = StarterPack.generateUser(
        uid: uid,
        name: name,
        email: email,
      );
      await _userController.saveUser(newUser: newUser);

      if (wallet.isEmpty) {
        WalletModel defaultWallet = StarterPack.defaultWallet;
        await _walletController.createWallet(defaultWallet);
      }
      await _userController.loadData();
      await _walletController.loadData();
    }
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
