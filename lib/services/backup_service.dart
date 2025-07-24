import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'storage_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create backup
  Future<String> createBackup({bool includeLocalData = true}) async {
    try {
      final backupData = <String, dynamic>{};

      // Add metadata
      backupData['version'] = '1.0';
      backupData['createdAt'] = DateTime.now().toIso8601String();
      backupData['deviceInfo'] = await _getDeviceInfo();

      if (includeLocalData) {
        // Export data from storage service
        final exportedData = _storageService.exportData();
        backupData.addAll(exportedData);
      }

      // Convert to JSON string
      final jsonString = jsonEncode(backupData);

      // Save to file
      final fileName =
          'tuition_helper_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = await _saveBackupFile(fileName, jsonString);

      return filePath;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  // Restore from backup
  Future<void> restoreFromBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup data
      if (!_validateBackupData(backupData)) {
        throw Exception('Invalid backup file format');
      }

      // Import data
      await _storageService.importData(backupData);
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  // Auto backup
  Future<void> autoBackup() async {
    try {
      final lastBackup = await _storageService.getSetting<String>(
        'last_auto_backup',
      );
      final now = DateTime.now();

      if (lastBackup != null) {
        final lastBackupDate = DateTime.parse(lastBackup);
        final daysSinceLastBackup = now.difference(lastBackupDate).inDays;

        // Skip if backup was created less than 7 days ago
        if (daysSinceLastBackup < 7) {
          return;
        }
      }

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return; // Skip if no internet connection
      }

      // Create backup
      final backupPath = await createBackup();

      // Save backup info
      await _storageService.saveSetting(
        'last_auto_backup',
        now.toIso8601String(),
      );
      await _storageService.saveSetting('last_backup_path', backupPath);

      // Clean up old backups
      await _cleanupOldBackups();
    } catch (e) {
      debugPrint('Auto backup failed: $e');
    }
  }

  // Export to external storage
  Future<String?> exportToExternalStorage() async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }

      // Create backup
      final backupData = _storageService.exportData();
      final jsonString = jsonEncode(backupData);

      // Let user choose location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName:
            'tuition_helper_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonString);
        return result;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to export backup: $e');
    }
  }

  // Import from external storage
  Future<void> importFromExternalStorage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await restoreFromBackup(result.files.single.path!);
      }
    } catch (e) {
      throw Exception('Failed to import backup: $e');
    }
  }

  // Cloud backup (if user is authenticated)
  Future<String?> createCloudBackup() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection');
      }

      // Create backup data
      final backupData = _storageService.exportData();
      backupData['userId'] = user.uid;
      backupData['userEmail'] = user.email;

      final jsonString = jsonEncode(backupData);

      // Here you would implement Firebase Storage or another cloud service
      // For now, we'll save it locally and return the path
      final fileName =
          'cloud_backup_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = await _saveBackupFile(fileName, jsonString);

      return filePath;
    } catch (e) {
      throw Exception('Failed to create cloud backup: $e');
    }
  }

  // Get backup history
  Future<List<Map<String, dynamic>>> getBackupHistory() async {
    try {
      final backupsDir = await _getBackupsDirectory();
      final files = backupsDir
          .listSync()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      final backups = <Map<String, dynamic>>[];

      for (final file in files) {
        try {
          final stat = await file.stat();
          final jsonString = await file.readAsString();
          final data = jsonDecode(jsonString) as Map<String, dynamic>;

          backups.add({
            'path': file.path,
            'name': file.path.split('/').last,
            'size': stat.size,
            'createdAt': data['createdAt'] ?? stat.modified.toIso8601String(),
            'version': data['version'] ?? 'Unknown',
            'recordCount': _getRecordCount(data),
          });
        } catch (e) {
          debugPrint('Error reading backup file ${file.path}: $e');
        }
      }

      // Sort by creation date (newest first)
      backups.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

      return backups;
    } catch (e) {
      throw Exception('Failed to get backup history: $e');
    }
  }

  // Delete backup
  Future<void> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  // Validate backup data structure
  bool _validateBackupData(Map<String, dynamic> data) {
    final requiredKeys = ['version', 'createdAt', 'exportDate'];
    final dataKeys = [
      'guardians',
      'students',
      'sessions',
      'payments',
      'notifications',
      'locations',
    ];

    // Check if it has required metadata
    for (final key in requiredKeys) {
      if (!data.containsKey(key)) {
        return false;
      }
    }

    // Check if it has at least one data section
    return dataKeys.any((key) => data.containsKey(key));
  }

  // Get device info for backup metadata
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
  }

  // Save backup file to local storage
  Future<String> _saveBackupFile(String fileName, String content) async {
    final backupsDir = await _getBackupsDirectory();
    final file = File('${backupsDir.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  // Get backups directory
  Future<Directory> _getBackupsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupsDir = Directory('${appDir.path}/backups');
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }
    return backupsDir;
  }

  // Clean up old backup files
  Future<void> _cleanupOldBackups() async {
    try {
      final backupsDir = await _getBackupsDirectory();
      final files = backupsDir
          .listSync()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      // Sort by modification date
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );

      // Keep only the 10 most recent backups
      const maxBackups = 10;
      if (files.length > maxBackups) {
        for (int i = maxBackups; i < files.length; i++) {
          await files[i].delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up old backups: $e');
    }
  }

  // Get record count from backup data
  int _getRecordCount(Map<String, dynamic> data) {
    int count = 0;
    final dataKeys = [
      'guardians',
      'students',
      'sessions',
      'payments',
      'notifications',
      'locations',
    ];

    for (final key in dataKeys) {
      if (data[key] is List) {
        count += (data[key] as List).length;
      }
    }

    return count;
  }

  // Get backup file size in human readable format
  String getFileSizeString(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Schedule automatic backups
  Future<void> scheduleAutoBackup(Duration interval) async {
    await _storageService.saveSetting('auto_backup_enabled', true);
    await _storageService.saveSetting(
      'auto_backup_interval_hours',
      interval.inHours,
    );
  }

  // Disable automatic backups
  Future<void> disableAutoBackup() async {
    await _storageService.saveSetting('auto_backup_enabled', false);
  }

  // Check if auto backup is enabled
  Future<bool> isAutoBackupEnabled() async {
    return await _storageService.getSetting<bool>(
          'auto_backup_enabled',
          defaultValue: false,
        ) ??
        false;
  }
}
