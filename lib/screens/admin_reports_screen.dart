import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../utils/pdf_report_helper.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final stats = await _adminService.getDashboardStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _downloadPdfReport() async {
    if (_stats == null) return;

    // Show a loading indicator dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Preparing data and generating PDF report...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Fetch details asynchronously
      final users = await _adminService.getAllUsers();
      final rooms = await _adminService.getAllRooms();
      final bookings = await _adminService.getAllBookings();

      // Generate and download
      await PdfReportHelper.generateAndDownloadReport(
        stats: _stats!,
        users: users,
        rooms: rooms,
        bookings: bookings,
      );
    } catch (e) {
      print('Error generating PDF report: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error generating PDF report'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Pop loading dialog
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Reports'),
        backgroundColor: const Color(0xFF3B5998),
        actions: [
          if (!_isLoading && _stats != null)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Download PDF Report',
              onPressed: _downloadPdfReport,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard('Total Users', '${_stats?['total_users'] ?? 0}', Icons.people, Colors.blue),
                  _buildStatCard('Total Rooms', '${_stats?['total_rooms'] ?? 0}', Icons.meeting_room, Colors.green),
                  _buildStatCard('Total Bookings', '${_stats?['total_bookings'] ?? 0}', Icons.book_online, Colors.orange),
                  _buildStatCard('Revenue / Month', '\$${_stats?['total_revenue']?.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money, Colors.purple),
                ],
              ),
            ),
    );
  }
}
