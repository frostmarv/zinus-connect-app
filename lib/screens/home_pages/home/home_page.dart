import 'package:flutter/material.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onNotificationTap: () {
          //  Notification Page
        },
      ),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  /// ===============================
  /// BODY SWITCHER
  /// ===============================
  Widget _buildBody() {
    switch (_currentIndex) {
      case 1:
        return _buildCenterPage('Zira Assistant');
      case 3:
        return _buildCenterPage('More');
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildCenterPage(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// ===============================
  /// HOME CONTENT
  /// ===============================
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),

          /// EHS
          _buildSectionHeader("EHS"),
          const SizedBox(height: 12),
          _buildMenuGrid([
            _buildMenuItem(
              "Incident Report",
              Icons.report_problem_rounded,
              const Color(0xFFEF4444),
              () => _comingSoon("Incident Report"),
            ),
            _buildMenuItem(
              "Safety Checklist",
              Icons.checklist_rounded,
              const Color(0xFF10B981),
              () => _comingSoon("Safety Checklist"),
            ),
            _buildMenuItem(
              "Emergency Contact",
              Icons.emergency_rounded,
              const Color(0xFFF59E0B),
              () => _comingSoon("Emergency Contact"),
            ),
          ]),
          const SizedBox(height: 24),

          /// HUMAN RESOURCE
          _buildSectionHeader("Human Resource"),
          const SizedBox(height: 12),
          _buildMenuGrid([
            _buildMenuItem(
              "Helpdesk HR",
              Icons.support_agent_rounded,
              const Color(0xFF3B82F6),
              () {
                //  HR Helpdesk Chat
              },
            ),
            _buildMenuItem(
              "Leave Request",
              Icons.event_available_rounded,
              const Color(0xFF10B981),
              () => _comingSoon("Leave Request"),
            ),
            _buildMenuItem(
              "Payslip",
              Icons.receipt_long_rounded,
              const Color(0xFF6366F1),
              () => _comingSoon("Payslip"),
            ),
          ]),
          const SizedBox(height: 24),

          /// GENERAL AFFAIR
          _buildSectionHeader("General Affair"),
          const SizedBox(height: 12),
          _buildMenuGrid([
            _buildMenuItem(
              "GA Helpdesk",
              Icons.headset_mic_rounded,
              const Color(0xFF0EA5E9),
              () {
                //  GA Helpdesk Chat
              },
            ),
            _buildMenuItem(
              "Facility Request",
              Icons.apartment_rounded,
              const Color(0xFFF59E0B),
              () => _comingSoon("Facility Request"),
            ),
            _buildMenuItem(
              "Inventory",
              Icons.inventory_2_rounded,
              const Color(0xFF64748B),
              () => _comingSoon("Inventory"),
            ),
          ]),
        ],
      ),
    );
  }

  /// ===============================
  /// COMPONENTS
  /// ===============================
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome to Zinus Connect",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Internal communication & helpdesk platform",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildMenuGrid(List<Widget> items) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: items,
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature - Coming Soon')));
  }
}
