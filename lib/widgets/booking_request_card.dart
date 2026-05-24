import 'package:flutter/material.dart';
import 'package:app_rental_room/services/room_service.dart';

class BookingRequestCard extends StatefulWidget {
  final dynamic booking;
  final VoidCallback onRefresh;

  const BookingRequestCard({
    super.key,
    required this.booking,
    required this.onRefresh,
  });

  @override
  State<BookingRequestCard> createState() => _BookingRequestCardState();
}

class _BookingRequestCardState extends State<BookingRequestCard> {
  final RoomService _roomService = RoomService();
  bool _isProcessing = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isProcessing = true);
    final success = await _roomService.updateBookingStatus(
      widget.booking['booking_id'],
      status,
    );
    setState(() => _isProcessing = false);

    if (success) {
      widget.onRefresh();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final tenant = booking['tenant'];
    final room = booking['room'];
    final status = (booking['booking_status'] as String).toLowerCase();
    
    final bool isPending = status == 'pending';
    
    Color statusBgColor;
    Color statusTextColor;
    String statusLabel = status[0].toUpperCase() + status.substring(1);

    switch (status) {
      case 'confirmed':
        statusBgColor = Colors.green.shade100;
        statusTextColor = Colors.green;
        break;
      case 'cancelled':
        statusBgColor = Colors.red.shade100;
        statusTextColor = Colors.red;
        break;
      case 'pending':
      default:
        statusBgColor = Colors.orange.shade100;
        statusTextColor = Colors.orange.shade800;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF3B5998).withOpacity(0.1),
                  child: const Icon(Icons.person, color: Color(0xFF3B5998)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant != null ? tenant['name'] : 'Unknown User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tenant != null ? tenant['email'] : '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Room:',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        room != null ? room['room_name'] : 'Deleted Room',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Move-in Date:',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        booking['move_in_date'] ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Duration:',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        '${booking['total_months']} months',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus('cancelled'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus('confirmed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
