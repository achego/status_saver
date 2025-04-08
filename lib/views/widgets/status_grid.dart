import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:status_saver/app/models/status_model.dart';

class StatusGrid extends StatelessWidget {
  final List<StatusModel> statuses;
  final bool isLoading;
  final VoidCallback onRefresh;

  const StatusGrid({
    super.key,
    required this.statuses,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (statuses.isEmpty) {
      return Center(
        child: Text(
          'No statuses found',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        padding: const EdgeInsets.all(4),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          return StatusTile(status: status);
        },
      ),
    );
  }
}

class StatusTile extends StatelessWidget {
  final StatusModel status;

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
    // try {
    //   final messenger = ScaffoldMessenger.of(context);
    //   if (status.isVideo) {
    //     await GallerySaver.saveVideo(status.path);
    //   } else {
    //     await GallerySaver.saveImage(status.path);
    //   }
    //   messenger.showSnackBar(
    //     const SnackBar(content: Text('Status saved successfully!')),
    //   );
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error saving status: $e')),
    //   );
    // }
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
              // TODO: Implement status viewing
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
              // TODO: Implement sharing
            },
          ),
        ],
      ),
    );
  }
}
