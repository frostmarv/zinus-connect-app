// lib/widgets/camera/camera_processor.dart
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
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

    final ByteData logoData = await rootBundle.load(
      'assets/images/logo_zinus_tulisan.png',
    );
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final logo = img.decodeImage(logoBytes)!;

    final now = DateTime.now();
    final time = DateFormat("HH:mm").format(now);
    final date = DateFormat("dd/MM/yyyy").format(now);
    final day = DateFormat("E", "id_ID").format(now).substring(0, 3);

    const String fixedAddress =
        "Jl. H. Lebar No.1, RT.1/RW.5,\n"
        "Sukadamai, Kec. Cikupa,\n"
        "Kab. Tangerang, Banten 15710";

    final int margin = (image.width * 0.03).toInt(); // 3% dari lebar

    // Resize logo
    final resizedLogo = img.copyResize(logo, width: 56, height: 28);
    img.compositeImage(
      image,
      resizedLogo,
      dstX: margin,
      dstY: image.height - 300,
    );

    // Teks posisi relatif
    final int startTextY = image.height - 270;

    img.drawString(
      image,
      time,
      font: img.arial48,
      x: margin,
      y: startTextY,
      color: img.ColorRgba8(255, 255, 255, 255),
    );
    img.drawString(
      image,
      date,
      font: img.arial24,
      x: margin + 200,
      y: startTextY + 10,
      color: img.ColorRgba8(255, 255, 255, 255),
    );
    img.drawString(
      image,
      day,
      font: img.arial24,
      x: margin + 200,
      y: startTextY + 40,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    final List<String> addrLines = fixedAddress.split('\n');
    for (int i = 0; i < addrLines.length; i++) {
      img.drawString(
        image,
        addrLines[i],
        font: img.arial14,
        x: margin,
        y: startTextY + 80 + i * 20,
        color: img.ColorRgba8(255, 255, 255, 255),
      );
    }

    img.drawString(
      image,
      "Zinus Dream Indonesia",
      font: img.arial24,
      x: margin,
      y: startTextY + 150,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    img.drawString(
      image,
      "Kode Foto: ${config.code ?? 'LXZQ3004'}, Watermark Diverifikasi",
      font: img.arial14,
      x: margin,
      y: startTextY + 180,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    final out = img.encodeJpg(image, quality: 90);
    await File(outputPath).writeAsBytes(out);
  }
}
