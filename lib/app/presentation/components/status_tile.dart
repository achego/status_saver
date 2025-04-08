import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/shared/components/function_widgets.dart';
import 'package:status_saver/core/utils/app_assets.dart';
import 'package:status_saver/core/utils/date_time_extension.dart';
import 'package:status_saver/core/utils/file_utils.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';
import 'package:status_saver/app/presentation/screens/image_viewer.dart';

class StatusTile extends StatelessWidget {
  final StatusModel status;
  final bool isLarge;

  const StatusTile({
    super.key,
    required this.status,
    required this.isLarge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _handleFileAction(context),
          child: Stack(
            children: [
              Container(
                // clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: isLarge ? 0.8 : 1.2,
                    child: status.isVideo
                        ? _buildVideoThumbnail()
                        : Image.file(
                            File(status.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              if (!status.isSaved(context))
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: () => _saveStatus(context),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.all(3),
                        child: Container(
                          height: 28,
                          width: 28,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child:
                              svgAsset(AppSvgs.download, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(status.modifiedTime.timeAgo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                )),
      ],
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
      final savedPath = await FileUtils.saveStatus(File(status.path));
      print(savedPath);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status saved successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred while saving the status')),
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

  void _handleFileAction(BuildContext context) {
    switch (status.type) {
      case StatusType.image:
        _navigateToImageViewer(context);
        break;
      case StatusType.video:
        _navigateToVideoViewer(context);
        break;
    }
    return;
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

  void _navigateToVideoViewer(BuildContext context) {}

  void _navigateToImageViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          currentStatus: status,
          statuses: context.read<StatusViewModel>().imageStatuses,
        ),
      ),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        context.read<StatusViewModel>().refreshStatuses();
      }
    });
  }
}
