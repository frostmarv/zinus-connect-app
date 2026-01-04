class CameraWatermarkConfig {
  final String title;
  final String location;
  final String? code;
  final bool showTimestamp;

  const CameraWatermarkConfig({
    required this.title,
    required this.location,
    this.code,
    this.showTimestamp = true,
  });
}
