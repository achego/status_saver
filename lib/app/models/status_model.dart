import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';

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
      print('============================');
      print(status.path);
      print(path);
      print(status.path == path);
      print('============================');
      if (status.path == path) {
        return true;
      }
    }
    return false;
  }
}
