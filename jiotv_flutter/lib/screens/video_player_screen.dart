import 'package:flutter/material.dart';
import 'package:jiotv_flutter/services/channel_service.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final int channelId;

  const VideoPlayerScreen({super.key, required this.channelId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  final ChannelService _channelService = ChannelService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final result = await _channelService.getChannelUrl(widget.channelId);
    if (result is String && !result.startsWith('http')) {
      setState(() {
        _isLoading = false;
        _error = result;
      });
    } else if (result != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(result))
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
            _controller.play();
          });
        });
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Failed to get channel URL.';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text('Error: $_error')
                : _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const Text('Error: Could not play video.'),
      ),
    );
  }
}
