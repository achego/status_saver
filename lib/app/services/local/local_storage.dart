import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  late SharedPreferences _preference;

  Future<void> initializePref() async {
    _preference = await SharedPreferences.getInstance();
  }

  String? getSafDirectoryUri(
      {StorageFolders folder = StorageFolders.baseStatusFolder}) {
    try {
      final uris =
          _preference.getStringList(StorageKeys.safDirectoryUris) ?? [];
      final mappedUris =
          uris.map((e) => StorageUri.fromJson(jsonDecode(e))).toList();
      final uri = mappedUris
          .where((e) => e.name == folder.name)
          .map((e) => e.uri)
          .toList();
      if (uri.isEmpty) {
        return null;
      }
      return uri.first;
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveSafDirectoryUri(String uri,
      {StorageFolders folder = StorageFolders.baseStatusFolder}) async {
    try {
      final uris =
          _preference.getStringList(StorageKeys.safDirectoryUris) ?? [];
      final mappedUris =
          uris.map((e) => StorageUri.fromJson(jsonDecode(e))).toList();
      final exists = mappedUris.any((e) => e.uri == uri);
      if (exists) {
        return false;
      }
      final newUri = StorageUri(uri: uri, name: folder.name);
      uris.add(jsonEncode(newUri.toJson()));
      await _preference.setStringList(StorageKeys.safDirectoryUris, uris);
      return true;
    } catch (e) {
      return false;
    }
  }
}

enum StorageFolders {
  baseStatusFolder,
  waBusinessStatusFolder,
}

class StorageKeys {
  static const String safDirectoryUris = 'saf_directory_uris';
}

class StorageUri {
  final String uri;
  final String name;

  StorageUri({required this.uri, required this.name});

  factory StorageUri.fromJson(Map<String, dynamic> json) {
    return StorageUri(
      uri: json['uri'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      'name': name,
    };
  }

  StorageUri copyWith({
    String? uri,
    String? name,
  }) {
    return StorageUri(
      uri: uri ?? this.uri,
      name: name ?? this.name,
    );
  }
}

final localStorage = LocalStorage();
