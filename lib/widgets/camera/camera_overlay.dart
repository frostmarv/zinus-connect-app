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
    final day = DateFormat("E", "id_ID").format(now).substring(0, 3);

    const String fixedAddress =
        "Jl. H. Lebar No.1, RT.1/RW.5,\n"
        "Sukadamai, Kec. Cikupa,\n"
        "Kab. Tangerang, Banten 15710";

    final textScaler = MediaQuery.textScalerOf(context);
    final double baseScale = textScaler.scale(1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/logo_zinus_tulisan.png',
          height: 28 * baseScale,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36 * baseScale,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 2, color: Colors.yellow),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14 * baseScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    day,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14 * baseScale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          fixedAddress,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12 * baseScale,
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(191),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "Zinus Dream Indonesia",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12 * baseScale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.shield, size: 12, color: Colors.white70),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                "Kode Foto: ${config.code ?? 'LXZQ3004'}, Watermark Diverifikasi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10 * baseScale,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}