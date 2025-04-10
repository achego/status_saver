import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/app/presentation/components/action_button.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/components/video_progress_bar.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';
import 'package:status_saver/core/utils/app_assets.dart';
import 'package:video_player/video_player.dart';

class MediaViewerActions extends StatefulWidget {
  const MediaViewerActions({
    super.key,
    required this.statuses,
    required PageController pageController,
    required int currentIndex,
    required this.showActionButtons,
    this.videoController,
    this.onStatusAction,
  })  : _pageController = pageController,
        _currentIndex = currentIndex;

  final List<StatusModel> statuses;
  final PageController _pageController;
  final int _currentIndex;
  final bool showActionButtons;
  final VideoPlayerController? videoController;
  final VoidCallback? onStatusAction;

  @override
  State<MediaViewerActions> createState() => _MediaViewerActionsState();
}

class _MediaViewerActionsState extends State<MediaViewerActions> {
  bool isSaving = false;
  @override
  Widget build(BuildContext context) {
    StatusModel status;
    try {
      status = widget.statuses[widget._currentIndex];
    } catch (e) {
      status = StatusModel(
          path: '', type: StatusType.image, modifiedTime: DateTime.now());
    }
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        child: !widget.showActionButtons
            ? SizedBox.shrink()
            : Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.videoController != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: VideoProgressBar(
                            videoController: widget.videoController!),
                      ),
                      SizedBox(height: 5),
                    ],

                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.statuses.length,
                        itemBuilder: (context, index) {
                          final status = widget.statuses[index];
                          final isActive = widget._currentIndex == index;
                          return GestureDetector(
                            onTap: () {
                              widget._pageController.jumpToPage(index);
                            },
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: isActive ? 1.2 : 1,
                              child: Align(
                                alignment: Alignment.center,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 50,
                                  height: 50,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: !isActive ? 2 : 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      File(status.thumbnailPath ?? status.path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Action buttons
                    Consumer<StatusViewModel>(
                        builder: (context, viewModel, child) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 16,
                          top: 16,
                          left: 32,
                          right: 32,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ActionButton(
                              icon: AppSvgs.share,
                              onTap: () =>
                                  viewModel.shareStatus(context, status),
                            ),
                            ActionButton(
                              icon: AppSvgs.forward,
                              onTap: () =>
                                  viewModel.repostStatus(context, status),
                            ),
                            ActionButton(
                              isLoading: isSaving,
                              icon: status.isFromSaved(context)
                                  ? AppSvgs.delete
                                  : (status.isSaved(context)
                                      ? AppSvgs.favFilled
                                      : AppSvgs.download),
                              color:
                                  !status.isSaved(context) ? null : Colors.red,
                              onTap: () async {
                                setState(() => isSaving = true);
                                if (status.isFromSaved(context)) {
                                  await viewModel.deleteStatus(
                                    context,
                                    status,
                                  );
                                  // widget.statuses
                                  //     .removeAt(widget._currentIndex);
                                  setState(() {});
                                } else if (!status.isSaved(context)) {
                                  await viewModel.saveStatus(
                                    context,
                                    status,
                                  );
                                }
                                setState(() => isSaving = false);
                                widget.onStatusAction?.call();
                                if (widget.statuses.isEmpty) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}
