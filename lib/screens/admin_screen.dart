import 'package:flutter/material.dart';
import 'admin_users_screen.dart';
import 'admin_rooms_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_reports_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: const Color(0xFFD4A373)),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFFD4A373),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFEFAE0), Color(0xFFFAEDCD)],
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Welcome back! 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(context, 'Manage Users', Icons.people, const AdminUsersScreen()),
                  _buildDashboardCard(context, 'Manage Rooms', Icons.meeting_room, const AdminRoomsScreen()),
                  _buildDashboardCard(context, 'Manage Bookings', Icons.book_online, const AdminBookingsScreen()),
                  _buildDashboardCard(context, 'Reports', Icons.bar_chart, const AdminReportsScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
