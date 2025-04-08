import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({super.key, required this.videoController});

  final VideoPlayerController videoController;

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  @override
  void initState() {
    super.initState();
    _addVideoListener();
  }

  void _addVideoListener() {
    widget.videoController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDuration(widget.videoController.value.position),
            style: const TextStyle(color: Colors.white),
          ),
          Expanded(
              child: Slider(
            value: widget.videoController.value.position.inSeconds.toDouble(),
            max: widget.videoController.value.duration.inSeconds.toDouble(),
            activeColor: Colors.white,
            inactiveColor: Colors.white.withValues(alpha: 0.2),
            onChanged: (value) {
              widget.videoController.seekTo(
                Duration(seconds: value.toInt()),
              );
              setState(() {});
            },
          )),
          Text(
            _formatDuration(widget.videoController.value.duration),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
