import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MusicPlayer extends StatefulWidget {
  final String musicAsset;
  final bool isPlaying;
  final VoidCallback onTogglePlay;

  const MusicPlayer({
    super.key,
    required this.musicAsset,
    required this.isPlaying,
    required this.onTogglePlay,
  });

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  late final AudioPlayer _audioPlayer = AudioPlayer();
  Completer<void> _initCompleter = Completer<void>();


  @override
  void initState() {
    super.initState();
    _initPlayer();
  }


  Future<void> _initPlayer() async {
    try {
      await _audioPlayer.setSourceAsset(widget.musicAsset);
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    } catch (e) {
      debugPrint('Error setting music source: $e');
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }
  }
  Future<void> reloadAsset() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setSourceAsset(widget.musicAsset);

    } catch (e) {
      debugPrint('Error setting music source: $e');
    }
  }



  @override
  void didUpdateWidget(covariant MusicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.musicAsset != widget.musicAsset){
      _initCompleter = Completer<void>();
      _initPlayer();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Theme.of(context).iconTheme.color,
      ),
      onPressed: widget.onTogglePlay,
    );
  }
}