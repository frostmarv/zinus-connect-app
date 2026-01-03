import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  Timer? _failSafeTimer;

  @override
  void initState() {
    super.initState();
    // Hide system UI for a true fullscreen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.asset('assets/images/zinus_splash.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(false); // Ensure video plays only once
        _controller.play();
        // Add listener to navigate when video completes
        _controller.addListener(_checkVideoEnd);
      }).catchError((error) {
        // If video fails to load, navigate immediately
        _navigateToHome();
      });

    // Failsafe timer to navigate after 7 seconds, in case video gets stuck
    _failSafeTimer = Timer(const Duration(seconds: 7), _navigateToHome);
  }

  void _checkVideoEnd() {
    // Check if the video has finished playing
    if (_controller.value.isInitialized &&
        !_controller.value.isPlaying &&
        _controller.value.position >= _controller.value.duration) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    // Ensure navigation happens only once
    if (mounted) {
      _failSafeTimer?.cancel();
      // Restore system UI before leaving the splash screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // Use context to navigate if still mounted
      context.go('/');
    }
  }

  @override
  void dispose() {
    // Clean up listeners and controllers
    _controller.removeListener(_checkVideoEnd);
    _controller.dispose();
    _failSafeTimer?.cancel();
    // Restore system UI in case of an early exit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover, // This is the key change
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
    );
  }
}
