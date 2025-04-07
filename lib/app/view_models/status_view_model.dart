import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:status_saver/app/models/status_model.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

class StatusViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<Status> _statuses = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<Status> get imageStatuses => _statuses.where((s) => s.isImage).toList();
  List<Status> get videoStatuses => _statuses.where((s) => s.isVideo).toList();
  String? get error => _error;

  StatusViewModel() {
    _initializeAndLoadStatuses();
  }

  Future<void> _initializeAndLoadStatuses() async {
    await refreshStatuses();
  }

  Future<void> refreshStatuses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final externalStorage = await Permission.manageExternalStorage.request();
      if (!externalStorage.isGranted) {
        openAppSettings();
        return;
      }

      final whatsappDir = await _getWhatsAppStatusDirectory();
      if (whatsappDir == null) {
        throw Exception('WhatsApp status directory not found');
      }

      final statusFiles = await _getStatusFiles(whatsappDir);
      _statuses = await _processStatusFiles(statusFiles);
    } catch (e) {
      _error = e.toString();
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Directory?> _getWhatsAppStatusDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getApplicationDocumentsDirectory();

      final baseDir = directory.path.split('Android')[0];
      Directory(baseDir).listSync().forEach(
        (element) {
          print(element.path);
        },
      );
      final whatsappDir = Directory(
          '$baseDir/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');

      if (!whatsappDir.existsSync()) {
        // Try alternative path for newer Android versions
        final altWhatsappDir = Directory(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');
        if (altWhatsappDir.existsSync()) {
          return altWhatsappDir;
        }
        return null;
      }

      return whatsappDir;
    }
    return null;
  }

  Future<Directory?> showDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();

      if (directory == null) {
        return null;
      }

      final baseDir = directory.path.split('Android')[0];
      final me = await Directory(baseDir).list();
      // Android/media/com.whatsapp/WhatsApp/Media/
      // print(me);
      final path =
          '${baseDir}Android/media/com.whatsapp/WhatsApp/Media/.Statuses';
      print(path);
      Directory(path).listSync().forEach((element) {
        if (element is File) {
          print('File found: ${element.path}');

          if (element.path.endsWith('.jpg') ||
              element.path.endsWith('.png') ||
              element.path.endsWith('.mp4') ||
              element.path.endsWith('.avi')) {
            print('Image/Video file found: ${element.path}');
          }
        }
        // Check if the element is a hidden directory
        else if (element is Directory) {
          // If the directory is hidden (starts with a dot)
          if (element.path.startsWith('.')) {
            print('Hidden Directory: ${element.path}');
          } else {
            print('Directory: ${element.path}');
          }
        }
      });
      final whatsappDir = Directory(
          '$baseDir/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');

      if (!whatsappDir.existsSync()) {
        // Try alternative path for newer Android versions
        final altWhatsappDir = Directory(
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');
        if (altWhatsappDir.existsSync()) {
          return altWhatsappDir;
        }
        return null;
      }

      return whatsappDir;
    }
    return null;
  }

  Future<List<FileSystemEntity>> _getStatusFiles(Directory directory) async {
    if (!directory.existsSync()) return [];

    try {
      final files = directory.listSync();
      debugPrint('Found ${files.length} files in directory');
      files.forEach((file) => debugPrint('File: ${file.path}'));

      return files
          .where((entity) =>
              entity is File &&
              (entity.path.endsWith('.jpg') ||
                  entity.path.endsWith('.mp4') ||
                  entity.path.endsWith('.jpeg')))
          .toList();
    } catch (e) {
      debugPrint('Error listing directory: $e');
      return [];
    }
  }

  Future<List<Status>> _processStatusFiles(List<FileSystemEntity> files) async {
    final statuses = <Status>[];

    for (final file in files) {
      if (file is! File) continue;

      final path = file.path;
      final modifiedTime = file.lastModifiedSync();

      if (path.endsWith('.mp4')) {
        final thumbnailPath = await _generateVideoThumbnail(path);
        statuses.add(Status(
          path: path,
          type: StatusType.video,
          modifiedTime: modifiedTime,
          thumbnailPath: thumbnailPath,
        ));
      } else if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
        statuses.add(Status(
          path: path,
          type: StatusType.image,
          modifiedTime: modifiedTime,
        ));
      }
    }

    return statuses..sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));
  }

  Future<String?> _generateVideoThumbnail(String videoPath) async {
    try {
      // TODO: Implement video thumbnail generation
      return null;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }
}
