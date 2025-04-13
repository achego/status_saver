import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/components/media_viewer_actions.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({
    super.key,
    required this.currentStatus,
    required this.statuses,
  });

  final StatusModel currentStatus;
  final List<StatusModel> statuses;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool showActionButtons = false;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.statuses.indexOf(widget.currentStatus);
    _pageController = PageController(initialPage: _currentIndex);
    _initViewer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initViewer() {
    Future.delayed(const Duration(milliseconds: 700)).then((value) {
      setState(() => showActionButtons = true);
    });
  }

  toggleActionButtons() {
    setState(() => showActionButtons = !showActionButtons);
  }

  void _handleScaleStateChanged(PhotoViewScaleState scaleState) {
    final bool wasZoomed = _isZoomed;
    _isZoomed = scaleState != PhotoViewScaleState.initial;

    if (wasZoomed != _isZoomed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          GestureDetector(
            onTap: toggleActionButtons,
            child: PageView.builder(
              allowImplicitScrolling: false,
              physics: _isZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: widget.statuses.length,
              itemBuilder: (context, index) {
                final status = widget.statuses[index];
                return Hero(
                  tag: status.path,
                  child: PhotoView(
                    imageProvider: FileImage(File(status.path)),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    scaleStateChangedCallback: _handleScaleStateChanged,
                    backgroundDecoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: (_isZoomed || !showActionButtons)
                    ? const SizedBox.shrink()
                    : Container(
                        padding: EdgeInsets.only(top: 16),
                        child: AppBar(),
                      ),
              )),
          MediaViewerActions(
            showActionButtons: showActionButtons,
            statuses: widget.statuses,
            pageController: _pageController,
            currentIndex: _currentIndex,
            onStatusAction: () => setState(() {
              widget.statuses.removeAt(_currentIndex);
              if (_currentIndex > widget.statuses.length - 1) {
                _currentIndex = widget.statuses.length - 1;
              }
            }),
          ),
        ],
      ),
    );
  }
}
