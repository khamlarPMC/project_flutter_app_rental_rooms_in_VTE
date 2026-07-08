import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';
import 'admin_booking_detail_screen.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final AdminService _adminService = AdminService();
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    final bookings = await _adminService.getAllBookings();
    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  Future<void> _performDelete(int id) async {
    final success = await _adminService.deleteBooking(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchBookings();
    }
  }

  Future<void> _deleteBooking(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text(
          'Are you sure you want to permanently delete this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await _performDelete(id);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return const Color(0xFF16A34A);
      case 'cancelled': return const Color(0xFFDC2626);
      case 'expired':   return Colors.grey;
      case 'pending':
      default:          return const Color(0xFFD97706);
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return const Color(0xFFDCFCE7);
      case 'cancelled': return const Color(0xFFFEE2E2);
      case 'expired':   return const Color(0xFFF3F4F6);
      case 'pending':
      default:          return const Color(0xFFFEF3C7);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Icons.check_circle_outline;
      case 'cancelled': return Icons.cancel_outlined;
      case 'expired':   return Icons.timer_off_outlined;
      default:          return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        backgroundColor: const Color(0xFFD4A373),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings found'))
              : RefreshIndicator(
                  onRefresh: _fetchBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final status = booking.bookingStatus.toLowerCase();
                      final dateFormat = DateFormat('dd MMM yyyy');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminBookingDetailScreen(
                                  booking: booking,
                                  onDelete: () => _performDelete(booking.bookingId!),
                                ),
                              ),
                            );
                            _fetchBookings();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row: tenant + status badge
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: const Color(0xFFD4A373).withValues(alpha: 0.15),
                                      child: const Icon(Icons.person, color: Color(0xFFD4A373), size: 22),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            booking.tenant?.name ?? 'Unknown Tenant',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            booking.tenant?.email ?? '',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusBg(status),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_statusIcon(status), size: 12, color: _statusColor(status)),
                                          const SizedBox(width: 4),
                                          Text(
                                            status[0].toUpperCase() + status.substring(1),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _statusColor(status),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Divider(color: Colors.grey.shade200, height: 1),
                                const SizedBox(height: 10),
                                // Room name
                                Row(
                                  children: [
                                    const Icon(Icons.meeting_room_outlined, size: 16, color: Color(0xFFD4A373)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        booking.room?.roomName ?? 'Deleted Room',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Dates
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.login, size: 14, color: Colors.green.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Move-in: ${dateFormat.format(booking.moveInDate)}',
                                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                        ),
                                      ],
                                    ),
                                    if (booking.moveOutDate != null) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.logout, size: 14, color: Colors.red.shade400),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Move-out: ${dateFormat.format(booking.moveOutDate!)}',
                                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Footer: view detail + delete
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tap to view details',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                                      tooltip: 'Delete Booking',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _deleteBooking(booking.bookingId!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
