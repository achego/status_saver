import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:status_saver/app/models/status_model.dart';
import 'package:status_saver/app/presentation/components/media_viewer_actions.dart';

class VideoViewer extends StatefulWidget {
  const VideoViewer({
    super.key,
    required this.currentStatus,
    required this.statuses,
  });

  final StatusModel currentStatus;
  final List<StatusModel> statuses;

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool showControls = true;
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.statuses.indexOf(widget.currentStatus);
    _pageController = PageController(initialPage: _currentIndex);
    _initializeVideo(widget.currentStatus);
  }

  Future<void> _initializeVideo(StatusModel status) async {
    _videoController = VideoPlayerController.file(File(status.path));

    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void toggleControls() {
    setState(() => showControls = !showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: toggleControls,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) async {
                setState(() {
                  _currentIndex = index;
                  _isInitialized = false;
                });
                await _videoController.dispose();
                await _initializeVideo(widget.statuses[index]);
              },
              itemCount: widget.statuses.length,
              itemBuilder: (context, index) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: _isInitialized
                        ? _videoController.value.aspectRatio
                        : 16 / 9,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isInitialized)
                          VideoPlayer(_videoController)
                        else
                          const CircularProgressIndicator(),

                        // Play/Pause Button Overlay
                        if (showControls)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_videoController.value.isPlaying) {
                                  _videoController.pause();
                                } else {
                                  _videoController.play();
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  _videoController.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: showControls
                  ? Theme.of(context)
                      .appBarTheme
                      .backgroundColor
                      ?.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),

          // Bottom Actions
          MediaViewerActions(
            videoController: _videoController,
            showActionButtons: showControls,
            statuses: widget.statuses,
            pageController: _pageController,
            currentIndex: _currentIndex,
          ),
        ],
      ),
    );
  }
}
