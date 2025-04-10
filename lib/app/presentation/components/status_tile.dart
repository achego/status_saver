import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/screens/image_viewer.dart';
import 'package:status_saver/app/presentation/screens/video_viewer.dart';
import 'package:status_saver/app/shared/components/function_widgets.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';
import 'package:status_saver/core/utils/app_assets.dart';
import 'package:status_saver/core/utils/date_time_extension.dart';

class StatusTile extends StatefulWidget {
  final StatusModel status;
  final bool isLarge;

  const StatusTile({
    super.key,
    required this.status,
    required this.isLarge,
  });

  @override
  State<StatusTile> createState() => _StatusTileState();
}

class _StatusTileState extends State<StatusTile> {
  bool isSaving = false;
  bool isSaved = false;
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<StatusViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _handleFileAction(context),
          child: Stack(
            children: [
              Container(
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
                    aspectRatio: widget.isLarge ? 0.8 : 1.2,
                    child: widget.status.isVideo
                        ? _buildVideoThumbnail()
                        : Image.file(
                            File(widget.status.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              if (widget.status.isVideo)
                Positioned(
                  right: 0,
                  top: 0,
                  left: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.4)),
                      child: Container(
                        height: 25,
                        width: 25,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.8),
                        ),
                        child: FittedBox(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (!widget.status.isSaved(context) && !isSaved)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: () => _handleSaveStatus(context),
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
                          child: isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : svgAsset(AppSvgs.download, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(widget.status.modifiedTime.timeAgo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                )),
      ],
    );
  }

  void _handleSaveStatus(BuildContext context) async {
    final viewModel = context.read<StatusViewModel>();
    setState(() {
      isSaving = true;
    });
    await viewModel.saveStatus(context, widget.status);
    setState(() {
      isSaving = false;
      isSaved = true;
    });
  }

  Widget _buildVideoThumbnail() {
    if (widget.status.thumbnailPath != null) {
      return Image.file(
        File(widget.status.thumbnailPath!),
        fit: BoxFit.cover,
      );
    }
    return Container(
      color: Colors.grey,
      child: const Icon(Icons.video_library, size: 48),
    );
  }

  void _handleFileAction(BuildContext context) {
    switch (widget.status.type) {
      case StatusType.image:
        _navigateToImageViewer(context);
        break;
      case StatusType.video:
        _navigateToVideoViewer(context);
        break;
    }
  }

  void _navigateToVideoViewer(BuildContext context) {
    final viewModel = context.read<StatusViewModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoViewer(
          currentStatus: widget.status,
          statuses: widget.status.isFromSaved(context)
              ? viewModel.savedVideoStatuses
              : viewModel.videoStatuses,
        ),
      ),
    );
    context.read<StatusViewModel>().refreshStatuses();
  }

  void _navigateToImageViewer(BuildContext context) {
    final viewModel = context.read<StatusViewModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          currentStatus: widget.status,
          statuses: widget.status.isFromSaved(context)
              ? viewModel.savedImageStatuses
              : viewModel.imageStatuses,
        ),
      ),
    );
    context.read<StatusViewModel>().refreshStatuses();
  }
}
