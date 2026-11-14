import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'backup_migrator.dart';
import 'crypto_service.dart';

class BackupService {
  static const String backupFileName = 'FinTale_Backup.fintale';

  Future<Map<String, dynamic>> getFullBackupData(
    Map<String, dynamic> userData,
    Map<String, dynamic> databaseData, {
    DateTime? now,
  }) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = packageInfo.version;
    final String buildNumber = packageInfo.buildNumber;
    DateTime time = now ?? DateTime.now();

    return {
      'metadata': {
        'app': 'FinTale',
        'app_version': appVersion,
        'build_number': buildNumber,
        'schema_version': BackupMigrator.currentSchemaVersion,
        'exported_at': time.millisecondsSinceEpoch,
      },
      'user': userData,
      'database': databaseData,
    };
  }

  Future<bool> exportData(
    Map<String, dynamic> userData,
    Map<String, dynamic> databaseData, {
    int mode = 0,
    String? password,
  }) async {
    try {
      DateTime now = DateTime.now();
      final Map<String, dynamic> fullBackupData = await getFullBackupData(
        userData,
        databaseData,
        now: now,
      );
      final String jsonString = jsonEncode(fullBackupData);

      final Uint8List fileBytes = CryptoService.buildFintaleFile(
        jsonString: jsonString,
        mode: mode,
        password: password,
      );

      final Directory directory = await getApplicationDocumentsDirectory();

      final String dateStr = DateFormat('ddMMMyyyy').format(now);
      final String filePath =
          '${directory.path}/FinTale_Backup_$dateStr.fintale';

      final File backupFile = File(filePath);
      await backupFile.writeAsBytes(fileBytes);

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(backupFile.path)],
          text: 'Backup Data FinTale',
        ),
      );

      if (result.status == ShareResultStatus.success) {
        return true;
      } else if (result.status == ShareResultStatus.dismissed) {
        return false;
      }
      return true;
    } catch (e) {
      debugPrint("[BACKUP ERROR] Gagal melakukan export: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> importData({String? storedPassword}) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result == null || result.files.single.size == 0) return null;

      final file = result.files.single;
      Uint8List fileBytes;

      if (file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      } else if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else {
        return null;
      }

      return await importDataFromBytes(
        fileBytes,
        storedPassword: storedPassword,
      );
    } catch (e) {
      debugPrint("[BACKUP ERROR] Terjadi kesalahan saat membaca file: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> importDataFromBytes(
    Uint8List fileBytes, {
    String? storedPassword,
    String? manualPassword,
  }) async {
    try {
      if (fileBytes.length > 6 &&
          utf8.decode(fileBytes.sublist(0, 4), allowMalformed: true) ==
              'FNTL') {
        final parsed = CryptoService.parseFintaleFile(fileBytes);

        if (parsed.mode == 0) {
          return _tryDecrypt(parsed);
        }

        if (parsed.mode == 1) {
          return _tryDecrypt(parsed);
        }

        if (manualPassword != null && manualPassword.isNotEmpty) {
          final result = _tryDecrypt(parsed, password: manualPassword);
          if (result != null && result['data'] != null) return result;

          return {
            'need_password': true,
            'wrong_password': true,
            'file_bytes': fileBytes,
          };
        }

        if (storedPassword != null && storedPassword.isNotEmpty) {
          final result = _tryDecrypt(parsed, password: storedPassword);
          if (result != null && result['data'] != null) return result;
        }

        final appResult = _tryDecrypt(parsed);
        if (appResult != null && appResult['data'] != null) return appResult;

        return {'need_password': true, 'file_bytes': fileBytes};
      }

      final String jsonString = utf8.decode(fileBytes);
      Map<String, dynamic> backupData = jsonDecode(jsonString);
      if (backupData.containsKey('metadata') &&
          backupData['metadata']['app'] == 'FinTale') {
        return {'data': backupData};
      }
      return null;
    } catch (e) {
      debugPrint("[BACKUP ERROR] Terjadi kesalahan saat membaca file: $e");
      return null;
    }
  }

  Map<String, dynamic>? _tryDecrypt(
    FintaleParseResult parsed, {
    String? password,
  }) {
    try {
      final jsonString = CryptoService.decryptPayload(
        parsed: parsed,
        password: password,
      );
      final Map<String, dynamic> backupData = jsonDecode(jsonString);
      if (backupData.containsKey('metadata') &&
          backupData['metadata']['app'] == 'FinTale') {
        return {'data': backupData};
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> uploadToDrive(
    auth.AuthClient client,
    Map<String, dynamic> userData,
    Map<String, dynamic> databaseData, {
    int mode = 0,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> fullBackupData = await getFullBackupData(
        userData,
        databaseData,
      );
      final driveApi = drive.DriveApi(client);

      final String jsonString = jsonEncode(fullBackupData);
      final Uint8List fileBytes = CryptoService.buildFintaleFile(
        jsonString: jsonString,
        mode: mode,
        password: password,
      );

      final Stream<List<int>> mediaStream = Stream.value(fileBytes);
      final drive.Media media = drive.Media(mediaStream, fileBytes.length);

      const String legacyFileName = 'FinTale_Backup.json';
      final fileList = await driveApi.files.list(
        q: "name = '$backupFileName' or name = '$legacyFileName'",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final String fileId = fileList.files!.first.id!;
        final drive.File updateFile = drive.File()..name = backupFileName;
        await driveApi.files.update(updateFile, fileId, uploadMedia: media);
      } else {
        final drive.File fileMetadata = drive.File()..name = backupFileName;
        await driveApi.files.create(fileMetadata, uploadMedia: media);
      }
      return true;
    } catch (e, stackTrace) {
      debugPrint("[BACKUP] Error uploading to Drive: $e\n$stackTrace");
      return false;
    }
  }

  Future<Map<String, dynamic>?> downloadFromDrive(
    auth.AuthClient client, {
    String? password,
  }) async {
    try {
      final driveApi = drive.DriveApi(client);

      const String legacyFileName = 'FinTale_Backup.json';
      final fileList = await driveApi.files.list(
        q: "name = '$backupFileName' or name = '$legacyFileName'",
      );
      if (fileList.files == null || fileList.files!.isEmpty) return null;

      final String fileId = fileList.files!.first.id!;
      final drive.Media response =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final List<int> bytes = [];
      await for (var data in response.stream) {
        bytes.addAll(data);
      }

      final Uint8List fileBytes = Uint8List.fromList(bytes);

      if (fileBytes.length > 6 &&
          utf8.decode(fileBytes.sublist(0, 4), allowMalformed: true) ==
              'FNTL') {
        final parsed = CryptoService.parseFintaleFile(fileBytes);

        if (parsed.mode == 2 && password == null) {
          return {'need_password': true};
        }

        try {
          final jsonString = CryptoService.decryptPayload(
            parsed: parsed,
            password: password,
          );
          final Map<String, dynamic> backupData = jsonDecode(jsonString);

          if (backupData.containsKey('metadata') &&
              backupData['metadata']['app'] == 'FinTale') {
            return {'data': backupData};
          }
          return null;
        } catch (e) {
          if (parsed.mode == 2) {
            return {'need_password': true, 'wrong_password': true};
          }
          return null;
        }
      }

      final String jsonString = utf8.decode(fileBytes);
      final Map<String, dynamic> backupData = jsonDecode(jsonString);
      if (backupData.containsKey('metadata') &&
          backupData['metadata']['app'] == 'FinTale') {
        return {'data': backupData};
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint("[BACKUP] Error downloading from Drive: $e\n$stackTrace");
      return null;
    }
  }
}
