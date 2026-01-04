// lib/widgets/camera/camera_config.dart
class CameraWatermarkConfig {
  final String title;
  final String? code;
  final bool showTimestamp;

  const CameraWatermarkConfig({
    required this.title,
    this.code,
    this.showTimestamp = true,
  });
}