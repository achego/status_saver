import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/screens/home_screen.dart';
import 'package:status_saver/app/presentation/screens/saved_statuses_screen.dart';
import 'package:status_saver/app/presentation/screens/settings_screen.dart';
import 'package:status_saver/core/utils/app_assets.dart';
import 'package:status_saver/core/utils/file_utils.dart';
import 'package:url_launcher/url_launcher.dart';
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
            screen: const SavedStatusesScreen()),
        BottomNavItemModel(
            label: 'Settings',
            icon: AppSvgs.settings,
            activeIcons: AppSvgs.settingsFilled,
            screen: const SettingsScreen()),
      ];

  void setActiveIndex(int index) {
    activeIndex = index;
    notifyListeners();
  }

  Future<void> initializeAndLoadStatuses() async {
    await refreshStatuses();
    await getSavedStatuses();
  }

  Future<void> getSavedStatuses() async {
    final statuses = await FileUtils.getSavedStatuses();
    savedStatuses = await _processStatusFiles(statuses, savedStatuses);
    notifyListeners();
  }

  Future<void> refreshStatuses() async {
    _isLoading = _statuses.isEmpty ? true : false;
    _error = null;
    notifyListeners();

    try {
      final whatsappDir = await _getWhatsAppStatusDirectory();
      if (whatsappDir == null) {
        throw Exception('WhatsApp status directory not found');
      }

      final statusFiles = await _getStatusFiles(whatsappDir);

      _statuses = await _processStatusFiles(statusFiles, _statuses);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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
      final files = await directory.list().toList();
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
      List<FileSystemEntity> files, List<StatusModel> existingStatuses) async {
    final statuses = <StatusModel>[];

    for (final file in files) {
      if (file is! File) continue;

      final path = file.path;
      final modifiedTime = file.lastModifiedSync();

      final existingStatus = existingStatuses.where(
        (element) => element.path == path,
      );
      final exists = existingStatus.isNotEmpty;

      if (path.endsWith('.mp4')) {
        statuses.add(StatusModel(
          path: path,
          type: StatusType.video,
          modifiedTime: modifiedTime,
          thumbnailPath: exists
              ? existingStatus.first.thumbnailPath
              : await _generateVideoThumbnail(path),
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
      XFile thumbnailFile = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        quality: 80,
      );
      print('Thumbnail path: ${thumbnailFile.path}');
      return thumbnailFile.path;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<String?> _generateVideoThumbnailForVideos(String videoPath) async {
    try {
      XFile thumbnailFile = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        quality: 80,
      );
      print('Thumbnail path: ${thumbnailFile.path}');
      return thumbnailFile.path;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

// Image Viewer
  Future<void> shareStatus(BuildContext context, StatusModel status) async {
    try {
      await Share.shareXFiles(
        [XFile(status.path)],
        text: 'Check out this status!',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing status')),
        );
      }
    }
  }

  Future<void> saveStatus(BuildContext context, StatusModel status) async {
    try {
      await FileUtils.saveStatus(File(status.path));
      await initializeAndLoadStatuses();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving status')),
        );
      }
    }
  }

  Future<void> repostStatus(BuildContext context, StatusModel status) async {
    try {
      // final uri = Uri.parse('whatsapp://send?text=');
      final file = File(status.path);
      final uri = Uri.parse(
          "whatsapp://send?phone=+2348108888888&text=Check%20this%20image&file=${file.path}");

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening WhatsApp')),
        );
      }
    }
  }

  Future<void> deleteStatus(BuildContext context, StatusModel status) async {
    try {
      await File(status.path).delete();
      await initializeAndLoadStatuses();
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        // Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting status')),
        );
      }
    }
  }
}
