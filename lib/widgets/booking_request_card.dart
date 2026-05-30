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

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final tenant = booking['tenant'];
    final room = booking['room'];
    final status = (booking['booking_status'] as String).toLowerCase();
    final bool isPending = status == 'pending';

    // Status color config
    Color statusBgColor;
    Color statusTextColor;
    IconData statusIcon;
    final String statusLabel = status[0].toUpperCase() + status.substring(1);

    switch (status) {
      case 'confirmed':
        statusBgColor = const Color(0xFFDCFCE7);
        statusTextColor = const Color(0xFF16A34A);
        statusIcon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        statusBgColor = const Color(0xFFFEE2E2);
        statusTextColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel_outlined;
        break;
      case 'pending':
      default:
        statusBgColor = const Color(0xFFFEF3C7);
        statusTextColor = const Color(0xFFD97706);
        statusIcon = Icons.hourglass_empty;
        break;
    }

    // Room info
    final String roomName = room != null ? room['room_name'] ?? 'Deleted Room' : 'Deleted Room';
    final dynamic priceRaw = room != null ? room['price_per_month'] : null;
    final String roomPrice = priceRaw != null ? '\$${double.tryParse(priceRaw.toString())?.toStringAsFixed(0) ?? priceRaw}' : 'N/A';

    // Address
    final address = room != null ? room['address'] : null;
    final String location = (address != null)
        ? '${address['village'] ?? ''}, ${address['district'] ?? ''}'.replaceAll(RegExp(r'^,\s*|,\s*$'), '')
        : '';

    // Dates
    final String moveInDisplay = _formatDate(booking['move_in_date']?.toString());
    final String moveOutDisplay = _formatDate(booking['move_out_date']?.toString());
    final int totalMonths = booking['total_months'] ?? 0;

    // Price calculation
    final double? price = priceRaw != null ? double.tryParse(priceRaw.toString()) : null;
    final String totalPrice = (price != null && totalMonths > 0)
        ? '\$${(price * totalMonths).toStringAsFixed(0)}'
        : 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Tenant info + Status ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF3B5998).withValues(alpha: 0.12),
                  child: const Icon(Icons.person, color: Color(0xFF3B5998), size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant != null ? tenant['name'] ?? 'Unknown' : 'Unknown User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tenant != null ? tenant['email'] ?? '' : '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (tenant?['phone'] != null && tenant!['phone'].toString().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              tenant['phone'],
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusTextColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 14),

            // ─── Room Info Block ───
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Room name + price per month
                  Row(
                    children: [
                      const Icon(Icons.meeting_room_outlined, size: 16, color: Color(0xFF3B5998)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          roomName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Text(
                        '$roomPrice / mo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B5998),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          location,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 12),

                  // Move-in / Move-out
                  Row(
                    children: [
                      Expanded(
                        child: _infoTile(
                          icon: Icons.login,
                          label: 'Move-in',
                          value: moveInDisplay,
                          iconColor: Colors.green.shade600,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey.shade200),
                      Expanded(
                        child: _infoTile(
                          icon: Icons.logout,
                          label: 'Move-out',
                          value: moveOutDisplay,
                          iconColor: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 12),

                  // Duration + Total Price
                  Row(
                    children: [
                      Expanded(
                        child: _infoTile(
                          icon: Icons.timelapse,
                          label: 'Duration',
                          value: '$totalMonths month${totalMonths != 1 ? 's' : ''}',
                          iconColor: Colors.orange.shade600,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey.shade200),
                      Expanded(
                        child: _infoTile(
                          icon: Icons.payments_outlined,
                          label: 'Total',
                          value: totalPrice,
                          iconColor: const Color(0xFF3B5998),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Action Buttons (only for pending) ───
            if (isPending) ...[
              const SizedBox(height: 14),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateStatus('cancelled'),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus('confirmed'),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
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

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
