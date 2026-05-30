import 'package:flutter/material.dart';

import '../core/constants/ui_dict.dart';
import '../core/utils/starter_pack.dart';
import '../data/app_database.dart';
import '../data/pref_service.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../services/auth_service.dart';
import '../services/backup_service.dart';
import '../services/local_auth_service.dart';
import '../services/notification_service.dart';

class SettingsController with ChangeNotifier {
  final PrefService _prefService;
  final AuthService _authService;
  bool _isHardwareBiometricSupported = false;

  SettingsController(this._prefService, this._authService) {
    _initHardwareCheck();
  }

  bool get isHideBalance => _prefService.isHideBalance;
  bool get isAppLock => _prefService.isAppLock;
  bool get isRpgMode => _prefService.isRpgMode;
  bool get isNotification => _prefService.isNotification;
  String get themeMode => _prefService.themeMode;
  String? get currentPinHash => _prefService.pinHash;
  bool get isBiometricActive => _prefService.isBiometric;
  bool get isHardwareBiometricSupported => _isHardwareBiometricSupported;

  Future<void> _initHardwareCheck() async {
    _isHardwareBiometricSupported =
        await LocalAuthService.isBiometricSupported();
    notifyListeners();
  }

  Future<void> changeHideBalance(bool value) async {
    await _prefService.setHideBalance(value);
    notifyListeners();
  }

  Future<bool> changeAppLock(BuildContext context, bool value) async {
    String? userEmail = _prefService.rawUser?['email'];
    if (value == true) {
      final result =
          await Navigator.pushNamed(
                context,
                '/create-pin',
                arguments: {
                  "currentPinHash": currentPinHash,
                  "userEmail": userEmail,
                },
              )
              as bool?;

      bool isPinCreated = result ?? false;
      if (!isPinCreated) return false;
    } else {
      final result =
          await Navigator.pushNamed(
                context,
                '/verify-pin',
                arguments: {
                  "savedPinHash": currentPinHash,
                  "isCancelable": true,
                  "isBiometricEnabled": isBiometricActive,
                  "title": UiDict.pinInput,
                  "userEmail": userEmail,
                },
              )
              as bool?;

      bool isAuthorized = result ?? false;
      if (!isAuthorized) return false;

      await _prefService.setBiometric(false);
      await changePinHash();
    }

    await _prefService.setAppLock(value);
    notifyListeners();
    return true;
  }

  Future<bool> changeBiometric(BuildContext context, bool value) async {
    bool isAuthorized = false;
    if (value) {
      isAuthorized = await LocalAuthService.authenticateBiometricOnly();
    } else {
      String? userEmail = _prefService.rawUser?['email'];
      final result =
          await Navigator.pushNamed(
                context,
                '/verify-pin',
                arguments: {
                  "savedPinHash": currentPinHash,
                  "isCancelable": true,
                  "isBiometricEnabled": isBiometricActive,
                  "title": UiDict.pinInput,
                  "userEmail": userEmail,
                },
              )
              as bool?;
      isAuthorized = result ?? false;
    }
    if (!isAuthorized) return false;

    await _prefService.setBiometric(value);
    notifyListeners();
    return true;
  }

  Future<void> changeRpgMode(bool value) async {
    await _prefService.setRpgMode(value);
    notifyListeners();
  }

  Future<bool> changeNotification(BuildContext context, bool value) async {
    if (value == true) {
      bool isGranted = await NotificationService().requestPermission();

      if (!isGranted) {
        return false;
      }
    } else {
      await NotificationService().cancelAllNotifications();
    }

    await _prefService.setNotification(value);
    notifyListeners();
    return true;
  }

  Future<void> changeThemeMode(String? value) async {
    if (value != null) {
      await _prefService.setThemeMode(value);
      notifyListeners();
    }
  }

  Future<void> changePinHash({String? value}) async {
    await _prefService.setPinHash(value);
  }

  Future<bool> handleResetPin(BuildContext context) async {
    String? userEmail = _prefService.rawUser?['email'];
    final result =
        await Navigator.pushNamed(
              context,
              '/create-pin',
              arguments: {
                "currentPinHash": currentPinHash,
                "userEmail": userEmail,
              },
            )
            as bool?;

    bool isPinCreated = result ?? false;
    if (!isPinCreated) return false;

    return true;
  }

  Future<Map<String, dynamic>> handleSignOut() async {
    try {
      await NotificationService().cancelAllNotifications();
      await _prefService.clearAll();
      await AppDatabase.instance.deleteDB();
      return {"success": true};
    } catch (e) {
      return {"success": false, "error": 'Connection failed:  $e'};
    }
  }

  Future<Map<String, dynamic>> handleResetData() async {
    try {
      UserModel? oldUser = _prefService.user;
      if (oldUser != null) {
        UserModel newUser = StarterPack.generateUser(
          uid: oldUser.uid,
          name: oldUser.name,
          email: oldUser.email,
        );
        WalletModel newWallet = StarterPack.defaultWallet;

        await NotificationService().cancelAllNotifications();

        await AppDatabase.instance.deleteDB();
        await _prefService.saveUser(newUser);

        return {"success": true, "wallet": newWallet};
      } else {
        return {"success": false, "error": 'User is null'};
      }
    } catch (e) {
      return {"success": false, "error": 'Error:  $e'};
    }
  }

  Future<bool> handleExportData() async {
    try {
      final Map<String, dynamic> dbData = await AppDatabase.instance
          .exportAllData();

      final Map<String, dynamic> userData = _prefService.rawUser ?? {};

      final bool isSuccess = await BackupService().exportData(userData, dbData);

      return isSuccess;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> handleImportData() async {
    try {
      final Map<String, dynamic>? backupData = await BackupService()
          .importData();

      if (backupData != null) {
        final Map<String, dynamic> dbData = backupData['database'];
        final Map<String, dynamic> userData = backupData['user'];

        await NotificationService().cancelAllNotifications();

        Map<String, dynamic>? currentUser = _prefService.rawUser;
        if (currentUser != null) {
          userData['uid'] = currentUser['uid'];
          userData['email'] = currentUser['email'];
        }

        await _prefService.saveRawUser(userData);
        bool isDbSuccess = await AppDatabase.instance.importDatabase(dbData);
        if (isDbSuccess) {
          return {"success": true, "load": true};
        }
      }
      return {"success": false, "load": false};
    } catch (e) {
      return {"success": false, "load": false, "error": 'Error:  $e'};
    }
  }

  Future<bool> handleBackupData() async {
    try {
      final Map<String, dynamic> dbData = await AppDatabase.instance
          .exportAllData();

      final Map<String, dynamic> userData = _prefService.rawUser ?? {};
      final client = await _authService.getDriveClient();
      bool isSuccess = false;

      if (client != null) {
        isSuccess = await BackupService().uploadToDrive(
          client,
          userData,
          dbData,
        );
      }

      return isSuccess;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> handleRestoreData() async {
    try {
      final client = await _authService.getDriveClient();
      if (client != null) {
        final Map<String, dynamic>? backupData = await BackupService()
            .downloadFromDrive(client);

        if (backupData != null) {
          final Map<String, dynamic> dbData = backupData['database'];
          final Map<String, dynamic> userData = backupData['user'];

          await NotificationService().cancelAllNotifications();

          Map<String, dynamic>? currentUser = _prefService.rawUser;
          if (currentUser != null) {
            userData['uid'] = currentUser['uid'];
            userData['email'] = currentUser['email'];
          }

          await _prefService.saveRawUser(userData);

          bool isDbSuccess = await AppDatabase.instance.importDatabase(dbData);
          if (isDbSuccess) {
            return {"success": true, "load": true};
          }
        }
      }
      return {"success": false, "load": false};
    } catch (e) {
      return {"success": false, "load": false, "error": 'Error:  $e'};
    }
  }
}
