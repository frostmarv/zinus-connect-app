// lib/widgets/camera/app_camera_page.dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  late CameraController _controller;

  bool _ready = false;
  bool _previewing = false;
  final bool _isFrontCamera = false;
  bool _isCaptureLocked = false;

  File? _result;

  // Orientation
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  CameraViewOrientation _viewOrientation = CameraViewOrientation.portrait;

  late AnimationController _rotationController;
  late Animation<double> _rotation;

  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  static const double _kThreshold = 0.7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotation = Tween(begin: 0.0, end: 0.0).animate(_rotationController);

    _startClock();
    _initCamera();
    _startAutoOrientation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;
    if (!_controller.value.isInitialized) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal inisialisasi kamera: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startAutoOrientation() {
    _sensorSub ??= accelerometerEventStream().listen((event) {
      if (_previewing || _isCaptureLocked) return;

      // Hanya aktifkan rotasi untuk kamera belakang
      if (_isFrontCamera) return;

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

      if (next == _viewOrientation) return;

      _viewOrientation = next;

      final angle = switch (next) {
        CameraViewOrientation.landscapeLeft => math.pi / 2,
        CameraViewOrientation.landscapeRight => -math.pi / 2,
        _ => 0.0,
      };

      _rotation = Tween(begin: _rotation.value, end: angle).animate(
        CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
      );

      _rotationController
        ..reset()
        ..forward();
    });
  }

  Future<void> _capture() async {
    _rotationController.stop();
    _isCaptureLocked = true;

    try {
      final raw = await _controller.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final out = File(
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal ambil foto: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCaptureLocked = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    _sensorSub?.cancel();
    _rotationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ================= UI =================

  Widget _cameraPreview() {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final mirror = _isFrontCamera && !_previewing;

    // ✅ Gunakan Container + FittedBox agar preview selalu fill screen
    return Container(
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Transform.scale(
            scaleX: mirror ? -1 : 1,
            child: CameraPreview(_controller),
          ),
        ),
      ),
    );
  }

  Widget _previewImage() {
    if (!_previewing || _result == null) return const SizedBox();
    return Positioned.fill(
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.8),
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Image.file(_result!, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _watermark() {
    if (_previewing) return const SizedBox();
    return Positioned(
      left: 16,
      top: 16,
      child: CameraOverlay(
        config: widget.watermarkConfig.copyWith(timestamp: _now),
      ),
    );
  }

  Widget _controls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _circle(Icons.image, () {}, size: 48),
                _circle(Icons.folder, () {}, size: 48),
                _circle(
                  _previewing ? Icons.check : Icons.camera_alt,
                  _previewing
                      ? () {
                          widget.onCapture(_result!);
                          Navigator.pop(context);
                        }
                      : _capture,
                  size: 72,
                ),
                _circle(Icons.note, () {}, size: 48),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () {}, child: const Text('VIDEO')),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('|', style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'FOTO',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('|', style: TextStyle(fontSize: 18)),
                ),
                TextButton(onPressed: () {}, child: const Text('ABSENSI')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap, {double size = 56}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ✅ Rotasi hanya diterapkan ke preview saja
            Transform.rotate(angle: _rotation.value, child: _cameraPreview()),
            _previewImage(),
            _watermark(),
            _controls(),
          ],
        ),
      ),
    );
  }
}