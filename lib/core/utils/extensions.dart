import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import 'package:path/path.dart' as path;

final safStream = SafStream();

extension StringExtension on String {
  String get toStorageUri {
    String cleanedPath = replaceFirst(RegExp(r'^\/?'), '');
    String encodedPath = Uri.encodeComponent('primary:$cleanedPath');
    return 'content://com.android.externalstorage.documents/tree/$encodedPath/document/$encodedPath';
  }

  String get toFolderPath {
    final RegExp docRegex = RegExp(r'document/([^/]+)$');
    final match = docRegex.firstMatch(this);
    if (match != null) {
      String encoded = match.group(1)!;
      String decoded = Uri.decodeComponent(encoded);
      if (decoded.startsWith('primary:')) {
        return decoded.replaceFirst('primary:', '');
      }
      return decoded;
    } else {
      throw FormatException('Invalid URI format');
    }
  }

  bool get isImage => endsWith('.jpg') || endsWith('.jpeg');
  bool get isVideo => endsWith('.mp4');
}

extension SafDocumentFileExtension on SafDocumentFile {
  bool get isImage => name.endsWith('.jpg') || name.endsWith('.jpeg');
  bool get isVideo => name.endsWith('.mp4');
}

extension SafDocumentFileListExtension on List<SafDocumentFile> {
  List<SafDocumentFile> get imageFiles => where((e) => e.isImage).toList();
  List<SafDocumentFile> get videoFiles => where((e) => e.isVideo).toList();

  Future<List<File>> cacheFiles() async {
    final files = <File>[];
    for (final file in this) {
      if (file.isDir) continue;
      final tmp = await getTemporaryDirectory();
      final newFile = File(path.join(tmp.path, file.name));

      if (await newFile.exists()) {
        files.add(newFile);
        continue;
      }
      await safStream.copyToLocalFile(file.uri, newFile.uri.path);

      await newFile.setLastModified(
          DateTime.fromMillisecondsSinceEpoch(file.lastModified));
      files.add(newFile);
    }
    return files;
  }
}
