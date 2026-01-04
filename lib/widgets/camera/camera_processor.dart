// lib/widgets/camera/camera_processor.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

import 'camera_config.dart';

class CameraProcessor {
  static Future<void> applyWatermark({
    required String inputPath,
    required String outputPath,
    required CameraWatermarkConfig config,

    /// 🔐 Timestamp dari UI (ANTI DRIFT)
    DateTime? capturedAt,
  }) async {
    final bytes = await File(inputPath).readAsBytes();
    final original = img.decodeImage(bytes)!;

    /// ============================================================
    /// 1️⃣ CROP KE RASIO 3:4 (PORTRAIT) — HASIL FOTO SAJA
    /// ============================================================
    late img.Image image;

    if (original.width / original.height > 3 / 4) {
      // Terlalu lebar → crop kiri & kanan
      final newWidth = (original.height * 3 / 4).round();
      final offsetX = (original.width - newWidth) ~/ 2;
      image = img.copyCrop(
        original,
        x: offsetX,
        y: 0,
        width: newWidth,
        height: original.height,
      );
    } else {
      // Terlalu tinggi → crop atas & bawah
      final newHeight = (original.width * 4 / 3).round();
      final offsetY = (original.height - newHeight) ~/ 2;
      image = img.copyCrop(
        original,
        x: 0,
        y: offsetY,
        width: original.width,
        height: newHeight,
      );
    }

    /// ============================================================
    /// 2️⃣ LOAD LOGO
    /// ============================================================
    final ByteData logoData =
        await rootBundle.load('assets/images/logo_zinus_tulisan.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final logo = img.decodeImage(logoBytes)!;
    final resizedLogo = img.copyResize(logo, width: 56, height: 28);

    /// ============================================================
    /// 3️⃣ DATA WATERMARK (ANTI DRIFT)
    /// ============================================================
    final DateTime now = capturedAt ?? DateTime.now();

    final String time = DateFormat("HH:mm").format(now);
    final String date = DateFormat("dd/MM/yyyy").format(now);
    final String day =
        DateFormat("E", "id_ID").format(now).substring(0, 3);

    const String fixedAddress =
        "Jl. H. Lebar No.1, RT.1/RW.5,\n"
        "Sukadamai, Kec. Cikupa,\n"
        "Kab. Tangerang, Banten 15710";

    /// ============================================================
    /// 4️⃣ POSISI WATERMARK (BOTTOM-ANCHORED 🔥)
    /// ============================================================
    final int margin = (image.width * 0.04).toInt();
    final int baseY = image.height - margin;

    const int watermarkHeight = 180; // 🔥 magic number dirapikan
    final int logoX = margin;
    final int logoY = baseY - watermarkHeight;

    final int textStartY = logoY + 36;

    /// ============================================================
    /// 5️⃣ DRAW LOGO
    /// ============================================================
    img.compositeImage(
      image,
      resizedLogo,
      dstX: logoX,
      dstY: logoY,
    );

    /// ============================================================
    /// 6️⃣ DRAW TEXT
    /// ============================================================

    // Jam
    img.drawString(
      image,
      time,
      font: img.arial48,
      x: logoX,
      y: textStartY,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    // Tanggal & Hari
    img.drawString(
      image,
      date,
      font: img.arial24,
      x: logoX + 180,
      y: textStartY + 10,
      color: img.ColorRgba8(255, 255, 255, 255),
    );
    img.drawString(
      image,
      day,
      font: img.arial24,
      x: logoX + 180,
      y: textStartY + 40,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    // Alamat
    final List<String> addrLines = fixedAddress.split('\n');
    for (int i = 0; i < addrLines.length; i++) {
      img.drawString(
        image,
        addrLines[i],
        font: img.arial14,
        x: logoX,
        y: textStartY + 80 + (i * 20),
        color: img.ColorRgba8(255, 255, 255, 255),
      );
    }

    // Nama perusahaan
    img.drawString(
      image,
      "Zinus Dream Indonesia",
      font: img.arial24,
      x: logoX,
      y: textStartY + 150,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    // Footer
    img.drawString(
      image,
      "Kode Foto: ${config.code ?? 'LXZQ3004'}, Watermark Diverifikasi",
      font: img.arial14,
      x: logoX,
      y: textStartY + 180,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    /// ============================================================
    /// 7️⃣ SAVE OUTPUT
    /// ============================================================
    final out = img.encodeJpg(image, quality: 90);
    await File(outputPath).writeAsBytes(out);
  }
}
