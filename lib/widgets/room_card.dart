import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../screens/detail_room_screen.dart';
import '../screens/book_room_screen.dart';
import '../services/auth_service.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    // Determine status color and text
    final bool isAvailable = room.roomStatus.toLowerCase() == 'available';
    final Color statusColor = isAvailable ? Colors.green : Colors.red;
    final String statusText = isAvailable ? 'Available' : 'Occupied';

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailRoomScreen(room: room),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image Carousel
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: room.images != null && room.images!.isNotEmpty
                        ? room.images!.length
                        : 1,
                    itemBuilder: (context, idx) {
                      if (room.images != null && room.images!.isNotEmpty) {
                        return Image.network(
                          room.images![idx].fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                      }
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Price Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0EAFC).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3B5998).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '\$${room.pricePerMonth.toStringAsFixed(0)}/mo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B5998),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Room Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.roomName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        room.address != null
                            ? '${room.address!.village}, ${room.address!.district}'
                            : 'Location not set',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (AuthService.currentUser?.roleId != 2)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: isAvailable
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookRoomScreen(room: room),
                                    ),
                                  );
                                }
                              : null, // Disable button if occupied
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable
                                ? const Color(0xFF3B5998)
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            isAvailable ? 'Book Now' : 'Occupied',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
