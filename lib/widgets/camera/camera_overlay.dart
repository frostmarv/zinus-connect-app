// lib/widgets/camera/camera_overlay.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'camera_config.dart';

class CameraOverlay extends StatelessWidget {
  final CameraWatermarkConfig config;

  const CameraOverlay({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final time = DateFormat("HH:mm").format(now);
    final date = DateFormat("dd/MM/yyyy").format(now);
    final day = DateFormat(
      "E",
      "id_ID",
    ).format(now).substring(0, 3); // Sen, Sel, Rab, dll

    const String fixedAddress =
        "Jl. H. Lebar No.1, RT.1/RW.5,\n"
        "Sukadamai, Kec. Cikupa,\n"
        "Kab. Tangerang, Banten 15710";

    // Menentukan posisi berdasarkan orientasi layar
    return LayoutBuilder(
      builder: (context, constraints) {
        return Positioned(
          // Jika landscape, posisi di kiri bawah; jika portrait, juga kiri bawah
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.transparent, // TRANSPARENT - Hanya overlay khusus
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LOGO ZINUS (Tanpa tulisan Timemark) - Diperbesar
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo_zinus_tulisan.png',
                      width: 56, // Diperbesar dari 48 ke 56
                      height: 28, // Diperbesar dari 24 ke 28
                      fit: BoxFit.contain,
                    ),
                  ],
                ),

                const SizedBox(height: 10), // Sedikit dikurangi
                /// JAM, PEMISAH, TANGGAL & HARI (SEJAJAR) - Ukuran teks dikurangi
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // JAM
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36, // Dikurangi dari 42
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(width: 10), // Sedikit dikurangi
                      // PEMISAH KUNING
                      Container(
                        width: 2, // Sedikit dikurangi ketebalan
                        color: Colors.yellow,
                      ),
                      const SizedBox(width: 10), // Sedikit dikurangi
                      // TANGGAL (ATAS) & HARI (BAWAH) - Ukuran teks dikurangi
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14, // Dikurangi dari 16
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            day,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14, // Dikurangi dari 16
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14), // Sedikit dikurangi
                /// ALAMAT TETAP (DIBREAK LINE) - Ukuran teks dikurangi
                Text(
                  fixedAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12, // Dikurangi dari 13
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),

                const SizedBox(height: 14), // Sedikit dikurangi
                /// NAMA PERUSAHAAN DENGAN OVERLAY ABU-ABU 75% - Ukuran teks dikurangi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(191), // OVERLAY ABU-ABU 75%
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Zinus Dream Indonesia",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12, // Dikurangi dari 14
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 14), // Sedikit dikurangi
                /// FOOTER: KODE FOTO + VERIFIKASI - Icon diganti shield
                Row(
                  children: [
                    const Icon(
                      Icons
                          .shield, // Diganti dari check_circle_outline ke shield
                      size: 12, // Ukuran dikurangi
                      color: Color.fromRGBO(255, 255, 255, 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Kode Foto: ${config.code ?? 'LXZQ3004'}, Watermark Diverifikasi",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10, // Dikurangi dari 11
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
