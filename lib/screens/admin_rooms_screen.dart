import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/room_model.dart';
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

  Future<void> _deleteRoom(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this room?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final success = await _adminService.deleteRoom(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room deleted')));
        _fetchRooms();
      }
    }
  }

  Future<void> _approveRoom(int id) async {
    setState(() => _isLoading = true);
    final success = await _adminService.approveRoom(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room approved successfully!'), backgroundColor: Colors.green),
      );
      _fetchRooms();
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to approve room.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        backgroundColor: const Color(0xFF3B5998),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? const Center(child: Text('No rooms found'))
              : ListView.builder(
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.meeting_room, color: Color(0xFF3B5998), size: 40),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  room.roomName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: room.isApproved ? Colors.green.shade50 : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: room.isApproved ? Colors.green.shade200 : Colors.orange.shade200,
                                  ),
                                ),
                                child: Text(
                                  room.isApproved ? 'Approved' : 'Pending',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: room.isApproved ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Owner: ${room.owner?.name ?? 'Unknown'}'),
                              Text('Price: \$${room.pricePerMonth.toStringAsFixed(2)} / month'),
                              Row(
                                children: [
                                  const Text('Status: '),
                                  Text(
                                    room.roomStatus,
                                    style: TextStyle(
                                      color: room.roomStatus.toLowerCase() == 'available' ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (!room.isApproved) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _approveRoom(room.roomId!),
                                    icon: const Icon(Icons.check, size: 16, color: Colors.white),
                                    label: const Text('Approve Room', style: TextStyle(fontSize: 12, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
