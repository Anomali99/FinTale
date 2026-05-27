import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  Future<bool> exportData(
    Map<String, dynamic> userData,
    Map<String, dynamic> databaseData,
  ) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String appVersion = packageInfo.version;
      final String buildNumber = packageInfo.buildNumber;
      DateTime now = DateTime.now();

      final Map<String, dynamic> fullBackupData = {
        'metadata': {
          'app': 'FinTale',
          'app_version': appVersion,
          'build_number': buildNumber,
          'exported_at': now.millisecondsSinceEpoch,
        },
        'user': userData,
        'database': databaseData,
      };

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
}
