class CameraWatermarkConfig {
  final String title;
  final String? code;
  final bool showTimestamp;
  final DateTime? timestamp;

  const CameraWatermarkConfig({
    required this.title,
    this.code,
    this.showTimestamp = true,
    this.timestamp,
  });

  CameraWatermarkConfig copyWith({
    String? title,
    String? code,
    bool? showTimestamp,
    DateTime? timestamp,
  }) {
    return CameraWatermarkConfig(
      title: title ?? this.title,
      code: code ?? this.code,
      showTimestamp: showTimestamp ?? this.showTimestamp,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
