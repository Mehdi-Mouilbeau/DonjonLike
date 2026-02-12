import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/routing/app_router.dart';
import '../../core/services/storage_service.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final VideoPlayerController _controller;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/video/intro.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      final v = _controller.value;
      if (v.isInitialized && v.duration != Duration.zero) {
        if (v.position >= v.duration && !_finishing) {
          _finishIntro();
        }
      }
    });
  }

  Future<void> _finishIntro() async {
    if (_finishing) return;
    _finishing = true;

    StorageService.setIntroShown(true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.nameEntry);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialized = _controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _finishIntro, // ✅ tap = skip
        child: Center(
          child: initialized
              ? FittedBox(
                  fit: BoxFit.cover, // plein écran sans bandes
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
