import 'package:flutter/material.dart';
import 'package:zinus_connect/screens/general_affair/limbah/limbah_input.dart';

class LimbahIndex extends StatelessWidget {
  const LimbahIndex({super.key});

  Widget _buildFloatingListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title module is coming soon.'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: color,
              ),
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withAlpha((0.9 * 255).round()), color.withAlpha((0.6 * 255).round())],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Limbah Management',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B), // ✅ Warna eksplisit — solusi utama!
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B), // untuk ikon back, dll
        automaticallyImplyLeading: true, // pastikan back button muncul
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const Text(
              'Limbah Module',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Waste operational & compliance management',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 28),

            // Scrollable menu items (gunakan Expanded agar tidak overflow di layar kecil)
            Expanded(
              child: Column(
                children: [
                  _buildFloatingListItem(
                    context: context,
                    icon: Icons.playlist_add_rounded,
                    title: 'Input Limbah',
                    subtitle: 'Create new waste record',
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LimbahInputScreen(),
                        ),
                      );
                    },
                  ),
                  _buildFloatingListItem(
                    context: context,
                    icon: Icons.history_rounded,
                    title: 'History',
                    subtitle: 'View waste transaction history',
                    color: const Color(0xFF6366F1),
                  ),
                  _buildFloatingListItem(
                    context: context,
                    icon: Icons.photo_library_rounded,
                    title: 'Evidence Gallery',
                    subtitle: 'Photo & document evidences',
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
