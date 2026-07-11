import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/room_model.dart';
import '../utils/app_constants.dart';
import 'detail_room_screen.dart';

class AdminRoomsScreen extends StatefulWidget {
  const AdminRoomsScreen({super.key});

  @override
  State<AdminRoomsScreen> createState() => _AdminRoomsScreenState();
}

class _AdminRoomsScreenState extends State<AdminRoomsScreen> {
  final AdminService _adminService = AdminService();
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    final rooms = await _adminService.getAllRooms();
    setState(() {
      _rooms = rooms;
      _isLoading = false;
    });
  }

  Future<void> _confirmDeleteRoom(int id) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Room Deletion'),
            content: const Text(
              'The owner has requested to delete this room.\nAre you sure you want to permanently delete it?',
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
        ) ??
        false;

    if (confirm) {
      final success = await _adminService.confirmDeleteRoom(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchRooms();
      }
    }
  }

  Future<void> _rejectDeletion(int id) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Reject Deletion Request'),
            content: const Text(
              'Are you sure you want to reject this deletion request? The room will remain active.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      final success = await _adminService.rejectDeletion(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deletion request rejected. Room is active again.'),
            backgroundColor: Colors.orange,
          ),
        );
        _fetchRooms();
      }
    }
  }

  Future<void> _deleteRoom(int id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this room?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      final success = await _adminService.confirmDeleteRoom(id);
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Room deleted')));
        _fetchRooms();
      }
    }
  }

  Future<void> _approveRoom(int id) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Approve Room'),
            content: const Text(
              'Are you sure you want to approve this room listing?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirm) return;

    setState(() => _isLoading = true);
    final success = await _adminService.approveRoom(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchRooms();
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to approve room.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
          ? Center(
              child: Text(
                'No rooms found',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            )
          : ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return Card(
                  color: AppColors.backgroundCard,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.meeting_room,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.roomName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: room.isApproved
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : AppColors.warning.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: room.isApproved
                                    ? AppColors.success.withValues(alpha: 0.3)
                                    : AppColors.warning.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              room.isApproved ? 'Approved' : 'Pending',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: room.isApproved
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Owner: ${room.owner?.name ?? 'Unknown'}',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          Text(
                            'Price: \$${room.pricePerMonth.toStringAsFixed(2)} / month',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          Row(
                            children: [
                              Text(
                                'Status: ',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              Text(
                                room.roomStatus,
                                style: TextStyle(
                                  color:
                                      room.roomStatus.toLowerCase() ==
                                          'pending_deletion'
                                      ? AppColors.error
                                      : room.roomStatus.toLowerCase() ==
                                            'available'
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (room.roomStatus.toLowerCase() ==
                              'pending_deletion')
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 32,
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _confirmDeleteRoom(room.roomId!),
                                      icon: const Icon(
                                        Icons.delete_forever,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Confirm',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 32,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _rejectDeletion(room.roomId!),
                                      icon: const Icon(Icons.undo, size: 14),
                                      label: const Text(
                                        'Reject',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.warning,
                                        side: BorderSide(
                                          color: AppColors.warning,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else if (!room.isApproved)
                            SizedBox(
                              height: 32,
                              child: ElevatedButton.icon(
                                onPressed: () => _approveRoom(room.roomId!),
                                icon: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Approve Room',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailRoomScreen(room: room),
                          ),
                        );
                      },
                      trailing:
                          room.roomStatus.toLowerCase() == 'pending_deletion'
                          ? Icon(Icons.hourglass_top, color: AppColors.error)
                          : IconButton(
                              icon: Icon(Icons.delete, color: AppColors.error),
                              onPressed: () => _deleteRoom(room.roomId!),
                            ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
