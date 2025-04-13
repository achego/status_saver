import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_whatsapp/share_whatsapp.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/screens/home_screen.dart';
import 'package:status_saver/app/presentation/screens/saved_statuses_screen.dart';
import 'package:status_saver/app/presentation/screens/settings_screen.dart';
import 'package:status_saver/app/services/local/local_storage.dart';
import 'package:status_saver/core/utils/app_assets.dart';
import 'package:status_saver/core/utils/extensions.dart';
import 'package:status_saver/core/utils/file_utils.dart';
import 'package:status_saver/core/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

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

class SettingsItemModel {
  String appVersion;
  String storageLocation;
  SettingsItemModel({
    this.appVersion = '',
    this.storageLocation = '',
  });
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

  final saf = SafUtil();
  final safStream = SafStream();

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

  SettingsItemModel settingsItem = SettingsItemModel();

  Future<bool> hasPermission() async {
    final statusFolderPath = 'com.whatsapp/WhatsApp/Media/.Statuses';
    try {
      final directoryUri = localStorage.getSafDirectoryUri();
      if (directoryUri == null) {
        return false;
      }
      await saf.child(directoryUri, statusFolderPath.split('/'));
      return true;
    } catch (e, s) {
      loggerEx(e, s);
      return false;
    }
  }

  void setActiveIndex(int index) {
    activeIndex = index;
    notifyListeners();
  }

  Future<void> initializeAndLoadStatuses() async {
    await refreshStatuses();
    await getSavedStatuses();
    initSettingsItem();
  }

  void initSettingsItem() async {
    PackageInfo.fromPlatform().then((value) {
      settingsItem.appVersion = value.version;
    });
    FileUtils.getSavedStatusesDirectory().then((value) {
      settingsItem.storageLocation = value.path;
    });
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
      final whatsappDirUri = localStorage.getSafDirectoryUri();
      if (whatsappDirUri == null) {
        throw Exception('WhatsApp status directory not found');
      }

      final statusSafFiles = await _getStatusFiles(whatsappDirUri);
      final statusFiles = await statusSafFiles.cacheFiles();
      _statuses = await _processStatusFiles(statusFiles, _statuses);
      _isLoading = false;
      notifyListeners();
    } catch (e, s) {
      loggerEx(e, s);
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<SafDocumentFile>> _getStatusFiles(String directoryUri) async {
    final statusFolderPath = 'com.whatsapp/WhatsApp/Media/.Statuses';

    try {
      final status = await saf.child(directoryUri, statusFolderPath.split('/'));
      if (status == null) {
        return [];
      }
      final statusFiles = await saf.list(status.uri);
      return statusFiles.where((e) => e.isImage || e.isVideo).toList();
    } catch (e, s) {
      loggerEx(e, s);
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

      if (path.isVideo) {
        statuses.add(StatusModel(
          path: path,
          type: StatusType.video,
          modifiedTime: modifiedTime,
          thumbnailPath: exists
              ? existingStatus.first.thumbnailPath
              : await _generateVideoThumbnail(path),
        ));
      } else if (path.isImage) {
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
    } catch (e, s) {
      loggerEx(e, s);
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
    } catch (e, s) {
      loggerEx(e, s);
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
    } catch (e, s) {
      loggerEx(e, s);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving status')),
        );
      }
    }
  }

  Future<void> repostStatus(BuildContext context, StatusModel status) async {
    try {
      final isWhatsAppInstalled =
          await shareWhatsapp.installed(type: WhatsApp.standard);
      if (!isWhatsAppInstalled) {
        return;
      }
      await shareWhatsapp.shareFile(XFile(status.path));
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

  Future<bool> requestPermission() async {
    final uri = "Android/media".toStorageUri;
    final selectedUri = await saf.pickDirectory(
        initialUri: uri, writePermission: true, persistablePermission: true);
    if (selectedUri == null) {
      return false;
    }
    localStorage.saveSafDirectoryUri(selectedUri.uri);

    return true;
  }

  Future<void> cleanUpTempDir(
      {Duration maxAge = const Duration(hours: 27)}) async {
    final dir = await getTemporaryDirectory();
    final now = DateTime.now();

    if (!dir.existsSync()) {
      return;
    }

    final files = dir.listSync();
    for (final file in files) {
      final stat = await file.stat();
      final age = now.difference(stat.modified);

      if (age > maxAge) {
        await file.delete();
      }
    }
  }
}
