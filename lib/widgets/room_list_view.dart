import 'package:flutter/material.dart';
import '../models/room_model.dart';
import 'room_card.dart';

class RoomListView extends StatelessWidget {
  final List<Room> rooms;
  final bool isLoading;

  const RoomListView({
    super.key,
    required this.rooms,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (rooms.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hotel,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No rooms available',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return RoomCard(room: rooms[index]);
        },
      ),
    );
  }
}
