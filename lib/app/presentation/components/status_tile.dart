import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_saver/app/models/status_model.dart';

class StatusTile extends StatelessWidget {
  final Status status;

  const StatusTile({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showStatusActions(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: status.isVideo
                  ? _buildVideoThumbnail()
                  : Image.file(
                      File(status.path),
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status.isVideo ? 'Video' : 'Image',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _saveStatus(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    if (status.thumbnailPath != null) {
      return Image.file(
        File(status.thumbnailPath!),
        fit: BoxFit.cover,
      );
    }
    return Container(
      color: Colors.grey,
      child: const Icon(Icons.video_library, size: 48),
    );
  }

  Future<void> _saveStatus(BuildContext context) async {
    try {
      final file = File(status.path);
      final bytes = await file.readAsBytes();

      // final result = await ImageGallerySaver.saveFile(
      //   status.path,
      //   name: 'status_${DateTime.now().millisecondsSinceEpoch}',
      // );

      // if (result['isSuccess'] == true) {
      //   if (context.mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Status saved successfully!')),
      //     );
      //   }
      // } else {
      //   throw Exception('Failed to save status');
      // }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving status: $e')),
        );
      }
    }
  }

  Future<void> _shareStatus(BuildContext context) async {
    try {
      await Share.shareXFiles(
        [XFile(status.path)],
        text: 'Check out this ${status.isVideo ? 'video' : 'image'} status!',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing status: $e')),
        );
      }
    }
  }

  void _showStatusActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.remove_red_eye),
            title: const Text('View'),
            onTap: () {
              Navigator.pop(context);
              // TODO(belema): Implement status viewing
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Save'),
            onTap: () {
              Navigator.pop(context);
              _saveStatus(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              _shareStatus(context);
            },
          ),
        ],
      ),
    );
  }
}
