import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  static const String backupFileName = 'FinTale_Backup.json';

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
        'exported_at': time.millisecondsSinceEpoch,
      },
      'user': userData,
      'database': databaseData,
    };
  }

  Future<bool> exportData(
    Map<String, dynamic> userData,
    Map<String, dynamic> databaseData,
  ) async {
    try {
      DateTime now = DateTime.now();
      final Map<String, dynamic> fullBackupData = await getFullBackupData(
        userData,
        databaseData,
        now: now,
      );
      final String jsonString = jsonEncode(fullBackupData);

      final Directory directory = await getApplicationDocumentsDirectory();

      final String dateStr = DateFormat('ddMMMyyyy').format(now);
      final String filePath = '${directory.path}/FinTale_Backup_$dateStr.json';

      final File backupFile = File(filePath);
      await backupFile.writeAsString(jsonString);

      final result = await Share.shareXFiles([
        XFile(backupFile.path),
      ], text: 'Backup Data FinTale');

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

  Future<Map<String, dynamic>?> importData() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        String jsonString = await file.readAsString();

        Map<String, dynamic> backupData = jsonDecode(jsonString);

        if (backupData.containsKey('metadata') &&
            backupData['metadata']['app'] == 'FinTale') {
          return backupData;
        } else {
          debugPrint("[BACKUP ERROR] File bukan dari FinTale yang valid.");
          return null;
        }
      }

      return null;
    } catch (e) {
      debugPrint("[BACKUP ERROR] Terjadi kesalahan saat membaca file: $e");
      return null;
    }
  }

  Future<bool> uploadToDrive(
    auth.AuthClient client,
    Map<String, dynamic> userData,
    Map<String, dynamic> databaseData,
  ) async {
    try {
      final Map<String, dynamic> fullBackupData = await getFullBackupData(
        userData,
        databaseData,
      );
      final driveApi = drive.DriveApi(client);

      final String jsonString = jsonEncode(fullBackupData);
      final List<int> dataBytes = utf8.encode(jsonString);
      final Stream<List<int>> mediaStream = Stream.value(dataBytes);
      final drive.Media media = drive.Media(mediaStream, dataBytes.length);

      final fileList = await driveApi.files.list(q: "name = '$backupFileName'");

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final String fileId = fileList.files!.first.id!;
        await driveApi.files.update(drive.File(), fileId, uploadMedia: media);
      } else {
        final drive.File fileMetadata = drive.File()..name = backupFileName;
        await driveApi.files.create(fileMetadata, uploadMedia: media);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> downloadFromDrive(
    auth.AuthClient client,
  ) async {
    try {
      final driveApi = drive.DriveApi(client);

      final fileList = await driveApi.files.list(q: "name = '$backupFileName'");
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

      final String jsonString = utf8.decode(bytes);
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }
}
