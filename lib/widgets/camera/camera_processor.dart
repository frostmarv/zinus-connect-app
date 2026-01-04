// lib/widgets/camera/camera_processor.dart
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart'; // Untuk membaca asset
import 'package:intl/intl.dart';
import 'camera_config.dart';

class CameraProcessor {
  static Future<void> applyWatermark({
    required String inputPath,
    required String outputPath,
    required CameraWatermarkConfig config,
  }) async {
    // Baca gambar hasil foto
    final bytes = await File(inputPath).readAsBytes();
    final image = img.decodeImage(bytes)!;

    // Baca logo dari asset
    final ByteData logoData = await rootBundle.load('assets/images/logo_zinus_tulisan.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final logo = img.decodeImage(logoBytes)!;

    // Format waktu
    final now = DateTime.now();
    final time = DateFormat("HH:mm").format(now);
    final date = DateFormat("dd/MM/yyyy").format(now);
    final day = DateFormat("E", "id_ID").format(now).substring(0, 3);

    const String fixedAddress =
        "Jl. H. Lebar No.1, RT.1/RW.5,\n"
        "Sukadamai, Kec. Cikupa,\n"
        "Kab. Tangerang, Banten 15710";

    // Penempatan watermark di kiri bawah
    final int margin = 16;
    final int padding = 12;

    // Gambar logo
    final int logoWidth = 56;
    final int logoHeight = 28;
    final resizedLogo = img.copyResize(logo, width: logoWidth, height: logoHeight);
    img.compositeImage(
      image,
      resizedLogo,
      dstX: margin + padding,
      dstY: image.height - (padding * 2 + 10 * 6 + 14 + 14 + 14 + 14 + 12 + 28 + 10), // Sesuaikan tinggi total
    );

    // Gambar jam (format HH:mm)
    img.drawString(
      image,
      time,
      font: img.arial24,
      x: margin + padding,
      y: image.height - (padding * 2 + 10 * 6 + 14 + 14 + 14 + 14 + 12),
      color: img.ColorRgb8(255, 255, 255),
    );

    // Gambar pemisah vertikal kuning
    for (int i = 0; i < 36; i++) { // Kira-kira tinggi jam
      for (int j = 0; j < 2; j++) { // Lebar garis
        if ((margin + padding + 36 + 10 + j) < image.width && 
            (image.height - (padding * 2 + 10 * 6 + 14 + 14 + 14 + 14 + 12) - 36 + i) >= 0) {
          image.setPixelRgba(
            margin + padding + 36 + 10 + j,
            image.height - (padding * 2 + 10 * 6 + 14 + 14 + 14 + 14 + 12) - 36 + i,
            255, 255, 0, 255, // Kuning
          );
        }
      }
    }

    // Gambar tanggal
    img.drawString(
      image,
      date,
      font: img.arial14,
      x: margin + padding + 36 + 10 + 10 + 2, // Sesuaikan posisi
      y: image.height - (padding * 2 + 10 * 6 + 14 + 14 + 14 + 12),
      color: img.ColorRgb8(255, 255, 255),
    );

    // Gambar hari
    img.drawString(
      image,
      day,
      font: img.arial14,
      x: margin + padding + 36 + 10 + 10 + 2,
      y: image.height - (padding * 2 + 10 * 6 + 14 + 14 + 12),
      color: img.ColorRgb8(255, 255, 255),
    );

    // Gambar alamat
    final List<String> addrLines = fixedAddress.split('\n');
    for (int i = 0; i < addrLines.length; i++) {
      img.drawString(
        image,
        addrLines[i],
        font: img.arial14,
        x: margin + padding,
        y: image.height - (padding * 2 + 10 * (6 - i) + 14 + 14 + 12),
        color: img.ColorRgb8(255, 255, 255),
      );
    }

    // Gambar nama perusahaan dengan background abu-abu
    final int companyY = image.height - (padding * 2 + 10 * 3 + 12);
    img.fillRect(
      image,
      x1: margin + padding,
      y1: companyY - 6,
      x2: margin + padding + 160, // Estimasi lebar teks
      y2: companyY + 16,
      color: img.ColorRgba8(128, 128, 128, 191), // Abu-abu 75% opacity
    );
    img.drawString(
      image,
      "Zinus Dream Indonesia",
      font: img.arial14,
      x: margin + padding + 10,
      y: companyY,
      color: img.ColorRgb8(255, 255, 255),
    );

    // Gambar footer kode foto
    img.drawString(
      image,
      "Kode Foto: ${config.code ?? 'LXZQ3004'}, Watermark Diverifikasi",
      font: img.arial14,
      x: margin + padding,
      y: image.height - (padding * 2 + 10),
      color: img.ColorRgb8(255, 255, 255),
    );

    // Simpan hasil
    final out = img.encodeJpg(image, quality: 90);
    await File(outputPath).writeAsBytes(out);
  }
}
