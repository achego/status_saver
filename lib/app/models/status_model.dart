enum StatusType { image, video }

class Status {
  final String path;
  final StatusType type;
  final DateTime modifiedTime;
  final String? thumbnailPath;

  Status({
    required this.path,
    required this.type,
    required this.modifiedTime,
    this.thumbnailPath,
  });

  bool get isVideo => type == StatusType.video;
  bool get isImage => type == StatusType.image;
}
