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
                content: Text("$title module is coming soon."),
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
              color: Colors.black.withAlpha(15),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 10),
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
                  colors: [color.withAlpha(230), color.withAlpha(153)],
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
          "Limbah Management",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            const Text(
              "Limbah Module",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Waste operational & compliance management",
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 28),

            /// MENU LIST
            _buildFloatingListItem(
              context: context,
              icon: Icons.playlist_add_rounded,
              title: "Input Limbah",
              subtitle: "Create new waste record",
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LimbahInputScreen()),
                );
              },
            ),

            _buildFloatingListItem(
              context: context,
              icon: Icons.history_rounded,
              title: "History",
              subtitle: "View waste transaction history",
              color: const Color(0xFF6366F1),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const LimbahHistoryPage()),
                // );
              },
            ),

            _buildFloatingListItem(
              context: context,
              icon: Icons.photo_library_rounded,
              title: "Evidence Gallery",
              subtitle: "Photo & document evidences",
              color: const Color(0xFF10B981),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const LimbahGalleryPage()),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }
}
