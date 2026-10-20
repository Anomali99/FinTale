import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/constants/ui_dict.dart';
import '../core/utils/starter_pack.dart';
import '../data/app_database.dart';
import '../data/pref_service.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../services/auth_service.dart';
import '../services/backup_migrator.dart';
import '../services/backup_service.dart';
import '../services/local_auth_service.dart';
import '../services/notification_service.dart';

class SettingsController with ChangeNotifier {
  final PrefService _prefService;
  final AuthService _authService;
  bool _isHardwareBiometricSupported = false;
  bool _isBypassLock = false;
  bool get isBypassLock => _isBypassLock;

  SettingsController(this._prefService, this._authService) {
    _initHardwareCheck();
  }

  String appVersion = 'v1.0.0';

  bool get isHideBalance => _prefService.isHideBalance;
  bool get isAppLock => _prefService.isAppLock;
  bool get isRpgMode => _prefService.isRpgMode;
  bool get isNotification => _prefService.isNotification;
  ThemeMode get themeMode => _prefService.themeMode;
  String? get currentPinHash => _prefService.pinHash;
  bool get isBiometricActive => _prefService.isBiometric;
  bool get isHardwareBiometricSupported => _isHardwareBiometricSupported;

  bool get isBackupEncryption => _prefService.isBackupEncryption;
  bool get isBackupUseCustom => _prefService.isBackupUseCustom;
  String? get backupCustomPassword => _prefService.backupCustomPassword;

  Future<void> _initHardwareCheck() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;

    _isHardwareBiometricSupported =
        await LocalAuthService.isBiometricSupported();
    notifyListeners();
  }

  Future<void> changeHideBalance(bool value) async {
    await _prefService.setHideBalance(value);
    notifyListeners();
  }

  Future<bool> changeAppLock(BuildContext context, bool value) async {
    String? username = _prefService.rawUser?['name'];
    if (value == true) {
      final result =
          await Navigator.pushNamed(
                context,
                '/create-pin',
                arguments: {
                  "currentPinHash": currentPinHash,
                  "userEmail": username,
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
                  "userEmail": username,
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

  Future<void> changeThemeMode(ThemeMode? value) async {
    if (value != null) {
      await _prefService.setThemeMode(value);
      notifyListeners();
    }
  }

  Future<void> changePinHash({String? value}) async {
    await _prefService.setPinHash(value);
  }

  Future<void> changeBackupEncryption(bool value) async {
    await _prefService.setBackupEncryption(value);
    if (!value) {
      await _prefService.setBackupUseCustom(false);
    }
    notifyListeners();
  }

  Future<void> changeBackupUseCustom(bool value) async {
    await _prefService.setBackupUseCustom(value);
    notifyListeners();
  }

  Future<void> changeBackupCustomPassword(String? value) async {
    await _prefService.setBackupCustomPassword(value);
    notifyListeners();
  }

  Future<bool> handleResetPin(BuildContext context) async {
    String? username = _prefService.rawUser?['name'];
    final result =
        await Navigator.pushNamed(
              context,
              '/create-pin',
              arguments: {
                "currentPinHash": currentPinHash,
                "userEmail": username,
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

  Future<bool> handleMigrateData(Map<String, dynamic>? backupData) async {
    if (backupData == null) return false;

    // Migrate backup from any older schema version to current
    final Map<String, dynamic> migrated = BackupMigrator.migrate(backupData);

    final Map<String, dynamic> dbData = migrated['database'] ?? {};
    final Map<String, dynamic> rawUserData = migrated['user'] ?? {};

    // Sanitize user data so fromJson won't crash on missing fields
    final Map<String, dynamic> userData = BackupMigrator.sanitizeUserData(
      rawUserData,
    );

    await NotificationService().cancelAllNotifications();

    Map<String, dynamic>? currentUser = _prefService.rawUser;
    if (currentUser != null) {
      userData['uid'] = currentUser['uid'];
      userData['email'] = currentUser['email'];
    }

    bool isDbSuccess = await AppDatabase.instance.importDatabase(dbData);
    if (isDbSuccess) {
      await _prefService.saveRawUser(userData);
    }
    return isDbSuccess;
  }

  Future<bool> handleExportData() async {
    _isBypassLock = true;
    try {
      final Map<String, dynamic> dbData = await AppDatabase.instance
          .exportAllData();
      final Map<String, dynamic> userData = _prefService.rawUser ?? {};

      int mode = 0; // raw
      String? password;
      if (isBackupEncryption) {
        if (isBackupUseCustom &&
            backupCustomPassword != null &&
            backupCustomPassword!.isNotEmpty) {
          mode = 2;
          password = backupCustomPassword;
        } else {
          mode = 1;
        }
      }

      final bool isSuccess = await BackupService().exportData(
        userData,
        dbData,
        mode: mode,
        password: password,
      );
      return isSuccess;
    } catch (e, stackTrace) {
      debugPrint("[SETTINGS] Error exporting data: $e\n$stackTrace");
      return false;
    } finally {
      _isBypassLock = false;
    }
  }

  /// Import from file picker — auto-tries stored password and app key before
  /// asking the user.
  Future<Map<String, dynamic>> handleImportData() async {
    _isBypassLock = true;
    try {
      final result = await BackupService().importData(
        storedPassword: backupCustomPassword,
      );
      if (result == null) return {"success": false, "load": false};
      if (result['need_password'] == true) return result;

      bool isSuccess = await handleMigrateData(result['data']);
      return {"success": isSuccess, "load": isSuccess};
    } catch (e) {
      return {"success": false, "load": false, "error": 'Error:  $e'};
    } finally {
      _isBypassLock = false;
    }
  }

  /// Retry decrypt with a user-typed password on already-loaded bytes.
  Future<Map<String, dynamic>> handleImportWithPassword({
    required Uint8List fileBytes,
    required String password,
  }) async {
    _isBypassLock = true;
    try {
      final result = await BackupService().importDataFromBytes(
        fileBytes,
        manualPassword: password,
      );
      if (result == null) return {"success": false, "load": false};
      if (result['need_password'] == true) return result;

      bool isSuccess = await handleMigrateData(result['data']);
      return {"success": isSuccess, "load": isSuccess};
    } catch (e) {
      return {"success": false, "load": false, "error": 'Error:  $e'};
    } finally {
      _isBypassLock = false;
    }
  }

  /// Import from intent bytes (file opened externally).
  Future<Map<String, dynamic>> handleImportFromIntent(
    Uint8List fileBytes,
  ) async {
    _isBypassLock = true;
    try {
      final result = await BackupService().importDataFromBytes(
        fileBytes,
        storedPassword: backupCustomPassword,
      );
      if (result == null) return {"success": false, "load": false};
      if (result['need_password'] == true) return result;

      bool isSuccess = await handleMigrateData(result['data']);
      return {"success": isSuccess, "load": isSuccess};
    } catch (e) {
      return {"success": false, "load": false, "error": 'Error:  $e'};
    } finally {
      _isBypassLock = false;
    }
  }

  Future<bool> handleBackupData() async {
    _isBypassLock = true;
    try {
      final Map<String, dynamic> dbData = await AppDatabase.instance
          .exportAllData();
      final Map<String, dynamic> userData = _prefService.rawUser ?? {};
      final client = await _authService.getDriveClient();
      bool isSuccess = false;

      int mode = 0;
      String? password;
      if (isBackupEncryption) {
        if (isBackupUseCustom &&
            backupCustomPassword != null &&
            backupCustomPassword!.isNotEmpty) {
          mode = 2;
          password = backupCustomPassword;
        } else {
          mode = 1;
        }
      }

      if (client != null) {
        isSuccess = await BackupService().uploadToDrive(
          client,
          userData,
          dbData,
          mode: mode,
          password: password,
        );
      }
      return isSuccess;
    } catch (e, stackTrace) {
      debugPrint("[SETTINGS] Error backing up data to Drive: $e\n$stackTrace");
      return false;
    } finally {
      _isBypassLock = false;
    }
  }

  Future<Map<String, dynamic>> handleRestoreData({String? password}) async {
    _isBypassLock = true;
    try {
      final client = await _authService.getDriveClient();
      if (client != null) {
        final result = await BackupService()
            .downloadFromDrive(client, password: password);
        if (result == null) return {"success": false, "load": false};
        if (result['need_password'] == true) return result;

        bool isSuccess = await handleMigrateData(result['data']);
        return {"success": isSuccess, "load": isSuccess};
      }
      return {"success": false, "load": false};
    } catch (e) {
      return {"success": false, "load": false, "error": 'Error:  $e'};
    } finally {
      _isBypassLock = false;
    }
  }
}
