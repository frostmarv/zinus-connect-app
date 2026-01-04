// lib/widgets/camera/app_camera_page.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'camera_overlay.dart';
import 'camera_config.dart';
import 'camera_processor.dart';
import 'camera_orientation_helper.dart';

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
  bool _previewing = false;
  File? _result;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final cam = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller.initialize();
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _capture() async {
    final raw = await _controller.takePicture();
    final dir = await getApplicationDocumentsDirectory();
    final out = File(
      '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await CameraProcessor.applyWatermark(
      inputPath: raw.path,
      outputPath: out.path,
      config: widget.watermarkConfig,
    );

    setState(() {
      _previewing = true;
      _result = out;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            /// ================== FRAME 3:4 ==================
            Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    /// ===== CAMERA / RESULT PREVIEW =====
                    Transform.rotate(
                      angle: CameraOrientationHelper.rotation(_controller),
                      child: _previewing
                          ? Image.file(_result!, fit: BoxFit.cover)
                          : CameraPreview(_controller),
                    ),

                    /// ============ WATERMARK PREVIEW ============
                    Align(
                      alignment: CameraOrientationHelper.watermarkAlignment(
                        _controller,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Transform.rotate(
                          angle: CameraOrientationHelper.rotation(_controller),
                          child: CameraOverlay(config: widget.watermarkConfig),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            /// ================= CONTROL BAR =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circle(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                  _circle(
                    icon: _previewing ? Icons.check : Icons.camera_alt,
                    size: 72,
                    onTap: _previewing
                        ? () {
                            widget.onCapture(_result!);
                            Navigator.pop(context);
                          }
                        : _capture,
                  ),
                  _circle(icon: Icons.flip_camera_ios),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle({
    required IconData icon,
    double size = 56,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
