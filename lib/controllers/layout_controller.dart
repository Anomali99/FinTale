import 'package:flutter/material.dart';

import '../core/utils/mission_extension.dart';
import '../data/local/pref_service.dart';
import '../models/user_model.dart';

class LayoutController extends ChangeNotifier with WidgetsBindingObserver {
  final PrefService _prefService;
  UserModel? currentUser;
  int selectedIndex = 0;

  LayoutController(this._prefService) {
    WidgetsBinding.instance.addObserver(this);

    _loadUserData();
  }

  bool get isRpg => _prefService.isRpgMode;

  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void _loadUserData() async {
    _performTimeCheck();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _performTimeCheck();
    }
  }

  void _performTimeCheck() {
    if (currentUser == null) return;

    bool isReset = currentUser!.progress.checkAndReset();

    if (isReset && currentUser != null) {
      _prefService.saveUser(currentUser!);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
