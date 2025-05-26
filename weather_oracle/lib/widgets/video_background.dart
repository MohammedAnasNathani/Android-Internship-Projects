import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoBackground extends StatefulWidget {
  final String videoPath;

  const VideoBackground({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoBackgroundState createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    print('Initializing video player with path: ${widget.videoPath}');
    try {
      _videoPlayerController = VideoPlayerController.asset(widget.videoPath);
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        showControls: false,
        placeholder: Container(
          color: Colors.black,
        ),
        errorBuilder: (context, errorMessage) {
          print('Error loading video: $errorMessage');
          return Center(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
      _isVideoInitialized = true;
      setState(() {});
    } catch (e) {
      print('Error initializing video player: $e');
      _isVideoInitialized = false;
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant VideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoPath != oldWidget.videoPath) {
      reinitializePlayer();
    }
  }

  Future<void> reinitializePlayer() async {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _isVideoInitialized = false;
    await initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideoInitialized && _chewieController != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoPlayerController.value.size.width,
            height: _videoPlayerController.value.size.height,
            child: Chewie(
              controller: _chewieController!,
            ),
          ),
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}