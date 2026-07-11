import 'package:flutter/material.dart';
import 'admin_users_screen.dart';
import 'admin_rooms_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_reports_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
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
              Icon(icon, size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.tr('adminDashboard')),
        backgroundColor: AppColors.primary,
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                l.tr('welcomeAdmin'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    l.tr('manageUsers'),
                    Icons.people,
                    const AdminUsersScreen(),
                  ),
                  _buildDashboardCard(
                    context,
                    l.tr('manageRooms'),
                    Icons.meeting_room,
                    const AdminRoomsScreen(),
                  ),
                  _buildDashboardCard(
                    context,
                    l.tr('manageBookings'),
                    Icons.book_online,
                    const AdminBookingsScreen(),
                  ),
                  _buildDashboardCard(
                    context,
                    l.tr('reports'),
                    Icons.bar_chart,
                    const AdminReportsScreen(),
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
