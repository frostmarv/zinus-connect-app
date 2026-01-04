import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper untuk rotasi preview & watermark berdasarkan sensor device
class CameraOrientationHelper {
  /// Rotasi camera preview & overlay (radian)
  static double rotation(CameraController controller) {
    final orientation = controller.value.deviceOrientation;

    switch (orientation) {
      case DeviceOrientation.landscapeLeft:
        return -90 * pi / 180;
      case DeviceOrientation.landscapeRight:
        return 90 * pi / 180;
      case DeviceOrientation.portraitDown:
        return 180 * pi / 180;
      case DeviceOrientation.portraitUp:
        return 0;
    }
  }

  /// Posisi watermark
  /// NOTE:
  /// Selalu bottomLeft karena posisi visual dikontrol oleh rotasi
  static Alignment watermarkAlignment(CameraController controller) {
    return Alignment.bottomLeft;
  }
}
