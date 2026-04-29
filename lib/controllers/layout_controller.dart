import 'package:flutter/material.dart';

import '../data/local/pref_service.dart';

class LayoutController with ChangeNotifier {
  final PrefService _prefService;
  int selectedIndex = 0;

  LayoutController(this._prefService);

  bool get isRpg => _prefService.isRpgMode;

  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
