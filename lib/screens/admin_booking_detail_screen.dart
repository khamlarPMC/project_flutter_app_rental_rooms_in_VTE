import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';

class AdminBookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const AdminBookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: const Color(0xFF3B5998),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildSection(
              title: 'Room Information',
              icon: Icons.meeting_room,
              content: Column(
                children: [
                  _buildDetailRow(
                    'Room Name',
                    booking.room?.roomName ?? 'Unknown',
                  ),
                  _buildDetailRow(
                    'Price',
                    booking.room != null
                        ? '\$${booking.room!.pricePerMonth}/mo'
                        : 'Unknown',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Tenant Information',
              icon: Icons.person,
              content: Column(
                children: [
                  _buildDetailRow('Name', booking.tenant?.name ?? 'Unknown'),
                  _buildDetailRow('Email', booking.tenant?.email ?? 'Unknown'),
                  _buildDetailRow(
                    'Phone',
                    booking.tenant?.phone ?? 'Not provided',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Booking Details',
              icon: Icons.date_range,
              content: Column(
                children: [
                  _buildDetailRow(
                    'Status',
                    booking.bookingStatus.toUpperCase(),
                    valueColor: _getStatusColor(booking.bookingStatus),
                  ),
                  if (booking.bookingDate != null)
                    _buildDetailRow(
                      'Booking Date',
                      DateFormat(
                        'yyyy-MM-dd HH:mm',
                      ).format(booking.bookingDate!),
                    ),
                  _buildDetailRow(
                    'Move-in Date',
                    DateFormat('yyyy-MM-dd').format(booking.moveInDate),
                  ),
                  if (booking.moveOutDate != null)
                    _buildDetailRow(
                      'Move-out Date',
                      DateFormat('yyyy-MM-dd').format(booking.moveOutDate!),
                    ),
                  _buildDetailRow(
                    'Total Months',
                    booking.totalMonths?.toString() ?? 'N/A',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF3B5998)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
