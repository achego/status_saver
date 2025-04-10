import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';
import 'package:status_saver/core/utils/file_utils.dart';

enum StatusType { image, video }

class StatusModel {
  final String path;
  final StatusType type;
  final DateTime modifiedTime;
  final String? thumbnailPath;

  StatusModel({
    required this.path,
    required this.type,
    required this.modifiedTime,
    this.thumbnailPath,
  });

  bool get isVideo => type == StatusType.video;
  bool get isImage => type == StatusType.image;

  bool isSaved(BuildContext context) {
    for (var status in context.read<StatusViewModel>().savedStatuses) {
      final originalFile = File(status.path);
      final currentFile = File(path);
      if (FileUtils.areFilesIdentical(originalFile, currentFile)) {
        return true;
      }
    }
    return false;
  }

  bool isFromSaved(BuildContext context) {
    final contains = context
        .read<StatusViewModel>()
        .savedStatuses
        .where((status) => status.path == path);
    return contains.isNotEmpty;
  }

  StatusModel copyWith({
    String? path,
    StatusType? type,
    DateTime? modifiedTime,
    String? thumbnailPath,
  }) {
    return StatusModel(
      path: path ?? this.path,
      type: type ?? this.type,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
