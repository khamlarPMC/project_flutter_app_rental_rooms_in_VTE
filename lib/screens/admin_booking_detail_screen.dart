import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';
import 'detail_room_screen.dart';

class AdminBookingDetailScreen extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onDelete;

  const AdminBookingDetailScreen({
    super.key,
    required this.booking,
    this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return const Color(0xFF16A34A);
      case 'cancelled': return const Color(0xFFDC2626);
      case 'expired':   return Colors.grey;
      case 'pending':
      default:          return const Color(0xFFD97706);
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return const Color(0xFFDCFCE7);
      case 'cancelled': return const Color(0xFFFEE2E2);
      case 'expired':   return const Color(0xFFF3F4F6);
      default:          return const Color(0xFFFEF3C7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final status = booking.bookingStatus.toLowerCase();
    final double totalCost = (booking.room?.pricePerMonth ?? 0) * (booking.totalMonths ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: const Color(0xFFD4A373),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Booking',
            onPressed: () async {
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

              if (confirm && context.mounted) {
                onDelete?.call();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ─── Status Banner ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getStatusBg(status),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(status).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _getStatusColor(status), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Booking Status: ${booking.bookingStatus.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _getStatusColor(status),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Room Information ───
            _buildSection(
              title: 'Room Information',
              icon: Icons.meeting_room,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDetailRow('Room Name', booking.room?.roomName ?? 'Deleted Room'),
                  _buildDetailRow(
                    'Price',
                    booking.room != null
                        ? '\$${booking.room!.pricePerMonth.toStringAsFixed(0)} / month'
                        : 'N/A',
                  ),
                  if (booking.room?.address != null)
                    _buildDetailRow(
                      'Location',
                      '${booking.room!.address!.village}, ${booking.room!.address!.district}',
                    ),
                  if (booking.room != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailRoomScreen(room: booking.room!),
                        ),
                      ),
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('View Room Photos & Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A373),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                          SizedBox(width: 8),
                          Text(
                            'This room has been removed from the system.',
                            style: TextStyle(fontSize: 13, color: Color(0xFFDC2626)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Tenant Information ───
            _buildSection(
              title: 'Tenant Information',
              icon: Icons.person,
              content: Column(
                children: [
                  _buildDetailRow('Name', booking.tenant?.name ?? 'Unknown'),
                  _buildDetailRow('Email', booking.tenant?.email ?? 'Unknown'),
                  _buildDetailRow('Phone', booking.tenant?.phone ?? 'Not provided'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Booking Details ───
            _buildSection(
              title: 'Booking Details',
              icon: Icons.date_range,
              content: Column(
                children: [
                  if (booking.bookingDate != null)
                    _buildDetailRow(
                      'Booking Date',
                      DateFormat('dd MMM yyyy, HH:mm').format(booking.bookingDate!),
                    ),
                  _buildDetailRow('Move-in Date', dateFormat.format(booking.moveInDate)),
                  if (booking.moveOutDate != null)
                    _buildDetailRow('Move-out Date', dateFormat.format(booking.moveOutDate!)),
                  _buildDetailRow(
                    'Duration',
                    '${booking.totalMonths ?? 0} month${(booking.totalMonths ?? 0) != 1 ? 's' : ''}',
                  ),
                  _buildDetailRow(
                    'Total Cost',
                    '\$${totalCost.toStringAsFixed(0)}',
                    valueColor: const Color(0xFFD4A373),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Delete button at bottom ───
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
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

                  if (confirm && context.mounted) {
                    onDelete?.call();
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Delete This Booking', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFD4A373), size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
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
