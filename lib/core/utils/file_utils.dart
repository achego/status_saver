import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static const String _savedStatusesDir = 'Download/BStatusSaver';

  static Future<Directory> getSavedStatusesDirectory() async {
    final directory = await getExternalStorageDirectory();

    final baseDir = Directory(directory?.path.split('Android').first ?? '');

    final savedStatusesDir =
        Directory(path.join(baseDir.path, _savedStatusesDir));

    if (!await savedStatusesDir.exists()) {
      await savedStatusesDir.create(recursive: true);
    }

    return savedStatusesDir;
  }

  static Future<String> saveStatus(File sourceFile) async {
    final savedDir = await getSavedStatusesDirectory();
    final fileName =
        'status_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourceFile.path)}';
    final savedFilePath = path.join(savedDir.path, fileName);

    await sourceFile.copy(savedFilePath);
    return savedFilePath;
  }

  static Future<List<File>> getSavedStatuses() async {
    final savedDir = await getSavedStatusesDirectory();
    if (!savedDir.existsSync()) return [];

    final files = await savedDir
        .list()
        .where((entity) => entity is File)
        .map((entity) => entity as File)
        .toList();

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  static bool areFilesIdentical(File file1, File file2) {
    try {
      if (file1.lengthSync() != file2.lengthSync()) return false;

      final bytes1 = file1.readAsBytesSync();
      final bytes2 = file2.readAsBytesSync();

      if (bytes1.length != bytes2.length) return false;

      for (var i = 0; i < bytes1.length; i++) {
        if (bytes1[i] != bytes2[i]) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
