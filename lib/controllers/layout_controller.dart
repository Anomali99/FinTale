import 'package:flutter/material.dart';

import '../data/local/pref_service.dart';

class LayoutController with ChangeNotifier {
  final PrefService _prefService;

  bool get isRpg => _prefService.isRpgMode;

  LayoutController(this._prefService);
}
