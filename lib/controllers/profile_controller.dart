import 'package:flutter/material.dart';

import '../data/local/pref_service.dart';
import '../models/user_model.dart';

class ProfileController with ChangeNotifier {
  final PrefService _prefService;

  UserModel? currentUser;
  bool isLoading = true;

  ProfileController(this._prefService) {
    loadData();
  }

  String? get username => currentUser?.name;

  Map<Enum, double> get userAllocations => currentUser?.skillAllocations ?? {};

  double getAllocation(Enum type) => userAllocations[type] ?? 0.0;

  BigInt get dailyPenalty => currentUser?.dailyPenalty ?? BigInt.zero;
  BigInt get currentDailyLimit => currentUser?.currentDailyLimit ?? BigInt.zero;
  BigInt get baseDailyLimit => currentUser?.baseDailyLimit ?? BigInt.zero;
  BigInt get emergencyAmount => currentUser?.emergencyAmount ?? BigInt.zero;
  BigInt get emergencyTotal => currentUser?.emergencyTotal ?? BigInt.zero;

  bool get isRpg => _prefService.isRpgMode;

  Future<void> loadData() async {
    isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      currentUser = _prefService.getUser();
    } catch (e) {
      debugPrint("An error occurred while loading profile: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveName(String name) async {
    try {
      if (currentUser != null) {
        currentUser!.updateName(name);
        await _prefService.saveUser(currentUser!);

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to save name: $e");
    }
  }

  Future<void> saveBaseDailyLimit(BigInt amount) async {
    try {
      if (currentUser != null) {
        currentUser!.updateBaseDailyLimit(amount);
        await _prefService.saveUser(currentUser!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to save base daily limit: $e");
    }
  }

  Future<void> saveEmergencyAmount(BigInt amount) async {
    try {
      if (currentUser != null) {
        currentUser!.updateEmergencyAmount(amount);
        await _prefService.saveUser(currentUser!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to save emergency amount: $e");
    }
  }
}
