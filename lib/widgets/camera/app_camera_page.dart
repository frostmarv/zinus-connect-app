// lib/widgets/camera/app_camera_page.dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // tambahan
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'camera_overlay.dart';
import 'camera_config.dart';
import 'camera_processor.dart';

enum CameraViewOrientation { portrait, landscapeLeft, landscapeRight }

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ✅ Tambah observer

  late CameraController _controller;
  bool _ready = false;
  bool _previewing = false;
  File? _result;
  bool _isFrontCamera = false;

  // 🔑 Sensor & Orientation — ✅ jadi nullable untuk defensive dispose
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  CameraViewOrientation _viewOrientation = CameraViewOrientation.portrait;
  bool _isCaptureLocked = false;

  // 🌀 Animasi Rotasi
  late AnimationController _rotationAnimController;
  late Animation<double> _rotationAnimation;

  // ⏱️ Real-time clock
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  static const double _kThreshold = 0.7;
  static const double _buttonSize = 56.0;
  static const double _buttonPadding = 24.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ daftar observer

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ Hanya di mobile (web tidak support kamera background)
    if (kIsWeb) return;

    if (!_controller.value.isInitialized) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Dispose saat app tidak aktif → hindari crash di Android
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Re-init saat kembali
      _initCamera();
    }
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  Future<void> _initCamera() async {
    try {
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
    } catch (e) {
      // Opsional: error handling jika kamera gagal init
      if (mounted) Navigator.pop(context); // atau show error
    }
  }

  void _startAutoOrientation() {
    // ✅ Cek ulang sebelum subscribe
    if (_sensorSub != null) return;

    _sensorSub = accelerometerEventStream().listen((event) {
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
        return;
      }

      if (next != _viewOrientation) {
        setState(() => _viewOrientation = next);

        final newAngle = switch (next) {
          CameraViewOrientation.landscapeLeft => math.pi / 2,
          CameraViewOrientation.landscapeRight => -math.pi / 2,
          _ => 0.0,
        };

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
    // 🔒 Freeze rotation animasi agar tidak "nyangkut"
    _rotationAnimController.stop();
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
        capturedAt: _now,
      );

      if (mounted) {
        setState(() {
          _previewing = true;
          _result = out;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCaptureLocked = false;
          // Opsional: reset animasi ke posisi aman
          _rotationAnimController.forward(from: 0);
        });
      }
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
    WidgetsBinding.instance.removeObserver(this); // ✅ cleanup observer
    _clockTimer?.cancel();
    _sensorSub?.cancel(); // ✅ aman karena nullable
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

    final shouldMirrorPreview = !_previewing && _isFrontCamera;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    final cameraFrame = AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: shouldMirrorPreview
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: CameraPreview(_controller),
                )
              : CameraPreview(_controller),
        ),
      ),
    );

    final watermark = !_previewing
        ? Positioned(
            left: 12,
            bottom: _buttonPadding + _buttonSize + _buttonPadding,
            child: CameraOverlay(
              config: widget.watermarkConfig.copyWith(timestamp: _now),
            ),
          )
        : const SizedBox();

    final rotatableLayer = Center(
      child: Transform.rotate(
        angle: _uiRotation,
        transformHitTests: false,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [cameraFrame, watermark],
        ),
      ),
    );

    final controlBar = Positioned(
      left: 0,
      right: 0,
      bottom: bottomSafeArea + _buttonPadding,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circle(icon: Icons.close, onTap: () => Navigator.pop(context)),
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
            _circle(icon: Icons.flip_camera_ios, onTap: _toggleCamera),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: Stack(children: [rotatableLayer, controlBar])),
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
