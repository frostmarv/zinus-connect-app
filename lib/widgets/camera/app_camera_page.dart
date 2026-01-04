// lib/widgets/camera/app_camera_page.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'camera_overlay.dart';
import 'camera_config.dart';
import 'camera_processor.dart';

class AppCameraPage extends StatefulWidget {
  final CameraWatermarkConfig watermarkConfig;
  final Function(File result) onCapture;

  const AppCameraPage({
    super.key,
    required this.watermarkConfig,
    required this.onCapture,
  });

  @override
  State<AppCameraPage> createState() => _AppCameraPageState();
}

class _AppCameraPageState extends State<AppCameraPage> {
  late CameraController _controller;
  bool _ready = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller.initialize();
      if (mounted) {
        setState(() => _ready = true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengakses kamera: $e')));
      }
    }
  }

  Future<void> _capture() async {
    if (!_ready || _isTakingPicture) return;
    setState(() => _isTakingPicture = true);

    try {
      final raw = await _controller.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final output = File(
        '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await CameraProcessor.applyWatermark(
        inputPath: raw.path,
        outputPath: output.path,
        config: widget.watermarkConfig,
      );

      if (mounted) {
        widget.onCapture(output);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
      }
    } finally {
      if (mounted) setState(() => _isTakingPicture = false);
    }
  }

  Future<void> _switchCamera() async {
    if (!_ready) return;
    final cameras = await availableCameras();
    final currentDirection = _controller.description.lensDirection;
    final nextCamera = cameras.firstWhere(
      (c) => c.lensDirection != currentDirection,
      orElse: () => cameras.first,
    );
    if (nextCamera == _controller.description) return;

    await _controller.dispose();
    _controller = CameraController(
      nextCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            CameraPreview(_controller),

            // Overlay Informasi
            CameraOverlay(config: widget.watermarkConfig),

            // Kontrol Kamera Bawah
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Cancel
                  _buildCircleButton(
                    icon: Icons.close,
                    color: Colors.grey.withAlpha(178),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Tombol Potret
                  _buildCircleButton(
                    icon: Icons.circle,
                    color: Colors.white,
                    size: 80,
                    innerCircle: true,
                    onPressed: _capture,
                  ),

                  // Tombol Ganti Kamera
                  _buildCircleButton(
                    icon: Icons.flip_camera_ios,
                    color: Colors.grey.withAlpha(178),
                    onPressed: _switchCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    double size = 60,
    bool innerCircle = false,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: innerCircle
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              )
            : Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}
