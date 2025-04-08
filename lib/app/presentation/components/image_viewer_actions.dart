import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/app/presentation/components/action_button.dart';
import 'package:status_saver/app/presentation/screens/image_viewer.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';
import 'package:status_saver/core/utils/app_assets.dart';

class ImageViewerActions extends StatelessWidget {
  const ImageViewerActions({
    super.key,
    required this.widget,
    required PageController pageController,
    required int currentIndex,
    required this.showActionButtons,
  })  : _pageController = pageController,
        _currentIndex = currentIndex;

  final ImageViewer widget;
  final PageController _pageController;
  final int _currentIndex;
  final bool showActionButtons;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        child: !showActionButtons
            ? SizedBox.shrink()
            : Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.statuses.length,
                        itemBuilder: (context, index) {
                          final status = widget.statuses[index];
                          final isActive = _currentIndex == index;
                          return GestureDetector(
                            onTap: () {
                              _pageController.jumpToPage(index);
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
                                      File(status.path),
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
                              onTap: () => viewModel.shareStatus(
                                  context, widget.statuses[_currentIndex]),
                            ),
                            ActionButton(
                              icon: AppSvgs.forward,
                              onTap: () => viewModel.saveStatus(
                                  context, widget.statuses[_currentIndex]),
                            ),
                            ActionButton(
                              icon: AppSvgs.delete,
                              color: Colors.red,
                              onTap: () => viewModel.deleteStatus(
                                context,
                                widget.statuses[_currentIndex],
                              ),
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
