import 'package:flutter/material.dart';
import './limbah/limbah_index.dart';

class GeneralAffairIndex extends StatelessWidget {
  const GeneralAffairIndex({super.key});

  Widget _buildMenuListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 0.6, color: Color(0xFFE2E8F0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "General Affair",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            /// HEADER
            const Text(
              "GA Modules",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "General affairs operational management",
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 24),

            /// LIMBAH
            _buildMenuListItem(
              context: context,
              icon: Icons.delete_outline_rounded,
              title: "Limbah",
              subtitle: "B3 & Non-B3 waste management",
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LimbahIndex()),
                );
              },
            ),
            _divider(),

            /// ELECTRICAL
            _buildMenuListItem(
              context: context,
              icon: Icons.electrical_services_rounded,
              title: "Electrical",
              subtitle: "Electrical inspection & maintenance",
              color: const Color(0xFFF59E0B),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const ElectricalIndex()),
                // );
              },
            ),
            _divider(),

            /// FUTURE MODULES
            _buildMenuListItem(
              context: context,
              icon: Icons.more_horiz_rounded,
              title: "Other GA Modules",
              subtitle: "Facility, Asset, Vehicle, Pantry, etc",
              color: const Color(0xFF6366F1),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
