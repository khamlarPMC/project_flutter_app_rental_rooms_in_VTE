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

  Future<void> _cancelBooking(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel Booking', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final success = await _adminService.cancelBooking(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
        _fetchBookings();
      }
    }
  }

  Future<void> _deleteBooking(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this booking entirely? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete Booking', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final success = await _adminService.deleteBooking(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking deleted successfully')));
        _fetchBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        backgroundColor: const Color(0xFF3B5998),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings found'))
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Room: ${booking.room?.roomName ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Tenant: ${booking.tenant?.name ?? 'Unknown'}\n'
                          'Move In: ${DateFormat('yyyy-MM-dd').format(booking.moveInDate)}\n'
                          'Status: ${booking.bookingStatus.toUpperCase()}',
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminBookingDetailScreen(booking: booking),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (booking.bookingStatus != 'cancelled')
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.orange),
                                tooltip: 'Cancel Booking',
                                onPressed: () => _cancelBooking(booking.bookingId!),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Booking',
                              onPressed: () => _deleteBooking(booking.bookingId!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
