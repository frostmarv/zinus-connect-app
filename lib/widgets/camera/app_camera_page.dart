// lib/widgets/camera/app_camera_page.dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'camera_overlay.dart';
import 'camera_config.dart';
import 'camera_processor.dart';

enum CameraViewOrientation {
  portrait,
  landscapeLeft, // HP diputar ke kiri (landscape kiri)
  landscapeRight, // HP diputar ke kanan (landscape kanan)
}

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

class _AppCameraPageState extends State<AppCameraPage>
    with TickerProviderStateMixin {
  late CameraController _controller;
  bool _ready = false;
  bool _previewing = false;
  File? _result;
  bool _isFrontCamera = false;

  // 🔑 Sensor & Orientation
  late StreamSubscription<AccelerometerEvent> _sensorSub;
  CameraViewOrientation _viewOrientation = CameraViewOrientation.portrait;
  bool _isCaptureLocked = false;

  // 🌀 Animasi Rotasi — DIPERBAIKI
  late AnimationController _rotationAnimController;
  late Animation<double> _rotationAnimation;

  // ⏱️ Real-time clock
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  // ⚙️ Threshold anti-goyang
  static const double _kThreshold = 0.7;

  // 📏 Konstanta untuk posisi watermark
  static const double _controlBarHeight = 120; // Tinggi control bar + padding

  @override
  void initState() {
    super.initState();

    _rotationAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(_rotationAnimController);

    _startClock();
    _initCamera();
    _startAutoOrientation();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final cam = cameras.firstWhere(
      (c) =>
          c.lensDirection ==
          (_isFrontCamera
              ? CameraLensDirection.front
              : CameraLensDirection.back),
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

  void _startAutoOrientation() {
    // ✅ FIX: Gunakan accelerometerEventStream() bukan accelerometerEvents
    _sensorSub = accelerometerEventStream().listen((event) {
      // 🔒 Freeze saat capture ATAU preview (hasil sudah tetap)
      if (_isCaptureLocked || _previewing) return;

      final x = event.x;
      final y = event.y;

      CameraViewOrientation next;
      if (y.abs() > x.abs() && y.abs() > _kThreshold) {
        next = CameraViewOrientation.portrait;
      } else if (x.abs() > y.abs() && x.abs() > _kThreshold) {
        next = x > 0
            ? CameraViewOrientation.landscapeLeft
            : CameraViewOrientation.landscapeRight;
      } else {
        return; // Tidak cukup miring → skip
      }

      if (next != _viewOrientation) {
        setState(() => _viewOrientation = next);

        final newAngle = switch (next) {
          CameraViewOrientation.landscapeLeft => -math.pi / 2,
          CameraViewOrientation.landscapeRight => math.pi / 2,
          _ => 0.0,
        };

        // ✅ ANIMASI ROTASI DIPERBAIKI — TIDAK PAKAI animateTo()
        final begin = _rotationAnimation.value;
        _rotationAnimation = Tween<double>(begin: begin, end: newAngle).animate(
          CurvedAnimation(
            parent: _rotationAnimController,
            curve: Curves.easeOut,
          ),
        );

        _rotationAnimController
          ..reset()
          ..forward();
      }
    });
  }

  Future<void> _capture() async {
    // 🔒 Lock orientasi & matikan sensor update
    setState(() => _isCaptureLocked = true);

    try {
      final raw = await _controller.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final out = File(
        '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await CameraProcessor.applyWatermark(
        inputPath: raw.path,
        outputPath: out.path,
        config: widget.watermarkConfig.copyWith(timestamp: _now),
        capturedAt: _now, // 🔥 FIX: Timestamp sinkron antara UI dan hasil foto
      );

      if (mounted) {
        setState(() {
          _previewing = true;
          _result = out;
          // Sensor otomatis freeze karena _previewing = true
        });
      }
    } catch (e) {
      // Opsional: error handling
      if (mounted) setState(() => _isCaptureLocked = false);
      rethrow;
    }
  }

  void _toggleCamera() async {
    if (_controller.value.isRecordingVideo) return;

    await _controller.dispose();
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _previewing = false;
      _result = null;
      _isCaptureLocked = false;
    });
    await _initCamera();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _sensorSub.cancel();
    _rotationAnimController.dispose();
    _controller.dispose();
    super.dispose();
  }

  double get _uiRotation => _rotationAnimation.value;

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🪞 Mirror hanya untuk preview kamera depan
    final shouldMirror = !_previewing && _isFrontCamera;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // LAYER 1: UI UTAMA (KAMERA, PREVIEW, TOMBOL) — BOLEH ROTATE
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, _) {
                Widget content = Column(
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
                            _previewing
                                ? Image.file(_result!, fit: BoxFit.cover)
                                : Transform.scale(
                                    scaleX: shouldMirror ? -1.0 : 1.0,
                                    child: CameraPreview(_controller),
                                  ),

                            // ✅ WATERMARK DI ATAS KAMERA — POSISI TEPAT DI ATAS TOMBOL KIRI
                            if (!_previewing)
                              Positioned(
                                left: 12,
                                bottom: _controlBarHeight + 12, // 🔥 SEJAJAR HORIZONTAL DENGAN TOMBOL KIRI
                                child: Transform.scale(
                                  scaleX: shouldMirror ? -1.0 : 1.0,
                                  child: CameraOverlay(
                                    config: widget.watermarkConfig.copyWith(
                                      timestamp: _now, // ✅ REAL-TIME
                                    ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
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
                          _circle(
                            icon: Icons.flip_camera_ios,
                            onTap: _toggleCamera,
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                // Jika mirror aktif → flip horizontal seluruh konten
                if (shouldMirror) {
                  content = Transform.scale(
                    scaleX: -1.0, // ✅ FIX: Gunakan scaleX, bukan Offset()
                    child: content,
                  );
                }

                // ✅ WAJIB: Aktifkan hit test agar tombol bisa diklik
                return Transform.rotate(
                  angle: _uiRotation,
                  transformHitTests: true, // 🔥 FIX: Tombol bisa diklik!
                  child: content,
                );
              },
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