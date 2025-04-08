import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/components/image_viewer_actions.dart';

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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.statuses.indexOf(widget.currentStatus);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool showActionButtons = true;

  toggleActionButtons() {
    setState(() => showActionButtons = !showActionButtons);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: toggleActionButtons,
            child: PageView.builder(
              allowImplicitScrolling: false,
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: widget.statuses.length,
              itemBuilder: (context, index) {
                final status = widget.statuses[index];
                return PhotoView(
                  imageProvider: FileImage(File(status.path)),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
          ImageViewerActions(
            showActionButtons: showActionButtons,
            widget: widget,
            pageController: _pageController,
            currentIndex: _currentIndex,
          ),
        ],
      ),
    );
  }
}
