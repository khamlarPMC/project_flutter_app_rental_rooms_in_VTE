import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/room_model.dart';
import 'book_room_screen.dart';
import '../services/auth_service.dart';

class DetailRoomScreen extends StatefulWidget {
  final Room room;

  const DetailRoomScreen({super.key, required this.room});

  @override
  State<DetailRoomScreen> createState() => _DetailRoomScreenState();
}

class _DetailRoomScreenState extends State<DetailRoomScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final int totalImages = room.images != null && room.images!.isNotEmpty
        ? room.images!.length
        : 1;
    final String title = room.roomName;
    final String price = '\$${room.pricePerMonth.toStringAsFixed(0)}/mo';
    final String location = room.address != null
        ? '${room.address!.village}, ${room.address!.district}'
        : 'Location not set';
    final String description = room.description ?? 'No description available.';
    final List<String> amenities =
        room.amenities?.map((a) => a.amenityName ?? '').toList() ?? [];

    // Role check: 3 = Admin, 2 = Owner
    final bool hideBookingButton =
        AuthService.currentUser?.roleId == 2 ||
        AuthService.currentUser?.roleId == 3;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
      appBar: AppBar(
        title: const Text('Room Details'),
        backgroundColor: const Color(0xFFD4A373),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: totalImages,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (room.images != null && room.images!.isNotEmpty) {
                        final imageUrl = room.images![index].fullImageUrl;
                        if (imageUrl.isEmpty) {
                          return Container(
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        }

                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFD4A373),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 64,
                                color: Colors.white70,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No images available',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Image Indicator
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        totalImages,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index
                                ? const Color(0xFFD4A373)
                                : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Image Count Badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1} / $totalImages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAEDCD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFD4A373,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          price,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4A373),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Owner Contact
                  if (room.owner != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A373).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFD4A373).withValues(alpha: 0.2),
                            child: const Icon(Icons.person, color: Color(0xFFD4A373), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.owner!.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (room.owner!.phone != null && room.owner!.phone!.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 14, color: Color(0xFFD4A373)),
                                      const SizedBox(width: 4),
                                      Text(
                                        room.owner!.phone!,
                                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    'No phone number',
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.contact_phone_outlined, color: Color(0xFFD4A373), size: 22),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Amenities
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: amenities
                        .map(
                          (amenity) => Chip(
                            label: Text(amenity),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: hideBookingButton
          ? null // Hide booking button for Owners and Admins
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookRoomScreen(room: widget.room),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A373),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book This Room',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}
