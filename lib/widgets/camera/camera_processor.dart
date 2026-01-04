import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'camera_config.dart';

class CameraProcessor {
  static Future<void> applyWatermark({
    required String inputPath,
    required String outputPath,
    required CameraWatermarkConfig config,
  }) async {
    final bytes = await File(inputPath).readAsBytes();
    final image = img.decodeImage(bytes)!;

    final now = DateTime.now();
    final lines = <String>[
      config.title,
      if (config.showTimestamp)
        DateFormat("dd/MM/yyyy HH:mm:ss").format(now),
      // ❌ HAPUS: config.location karena sudah ditampilkan di overlay
      if (config.code != null) "Kode: ${config.code}",
    ];

    img.drawString(
      image,
      lines.join("\n"),
      font: img.arial24,
      x: 20,
      y: image.height - (lines.length * 28 + 20),
      color: img.ColorRgb8(255, 255, 255),
    );

    final out = img.encodeJpg(image, quality: 90);
    await File(outputPath).writeAsBytes(out);
  }
}