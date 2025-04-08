import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/screens/home_screen.dart';
import 'package:status_saver/app/presentation/screens/saved_statuses_screen.dart';
import 'package:status_saver/core/utils/app_assets.dart';
import 'package:status_saver/core/utils/file_utils.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

class BottomNavItemModel {
  final String label;
  final String icon;
  final String activeIcons;
  final Widget screen;

  BottomNavItemModel(
      {required this.label,
      required this.icon,
      required this.activeIcons,
      required this.screen});
}

class StatusViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<StatusModel> _statuses = [];
  String? _error;
  List<StatusModel> savedStatuses = [];

  List<StatusModel> get savedImageStatuses =>
      savedStatuses.where((s) => s.isImage).toList();
  List<StatusModel> get savedVideoStatuses =>
      savedStatuses.where((s) => s.isVideo).toList();

  bool get isLoading => _isLoading;
  List<StatusModel> get imageStatuses =>
      _statuses.where((s) => s.isImage).toList();
  List<StatusModel> get videoStatuses =>
      _statuses.where((s) => s.isVideo).toList();

  int activeIndex = 0;

  List<BottomNavItemModel> get bottomNavItems => [
        BottomNavItemModel(
            label: 'Home',
            icon: AppSvgs.home,
            activeIcons: AppSvgs.homeFilled,
            screen: const HomeScreen()),
        BottomNavItemModel(
            label: 'Favorites',
            icon: AppSvgs.fav,
            activeIcons: AppSvgs.favFilled,
            screen: SavedStatusesScreen()),
      ];

  void setActiveIndex(int index) {
    activeIndex = index;
    notifyListeners();
  }

  StatusViewModel() {
    _initializeAndLoadStatuses();
  }

  Future<void> _initializeAndLoadStatuses() async {
    await refreshStatuses();
  }

  Future<void> getSavedStatuses() async {
    final statuses = await FileUtils.getSavedStatuses();
    savedStatuses = await _processStatusFiles(statuses);
    notifyListeners();
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

  Future<List<StatusModel>> _processStatusFiles(
      List<FileSystemEntity> files) async {
    final statuses = <StatusModel>[];

    for (final file in files) {
      if (file is! File) continue;

      final path = file.path;
      final modifiedTime = file.lastModifiedSync();

      if (path.endsWith('.mp4')) {
        final thumbnailPath = await _generateVideoThumbnail(path);
        statuses.add(StatusModel(
          path: path,
          type: StatusType.video,
          modifiedTime: modifiedTime,
          thumbnailPath: thumbnailPath,
        ));
      } else if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
        statuses.add(StatusModel(
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
