import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../screens/detail_room_screen.dart';
import '../screens/book_room_screen.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../utils/district_villages.dart';
import '../utils/app_constants.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isLao = LanguageProvider.instance.isLao;

    final bool isAvailable = room.roomStatus.toLowerCase() == 'available';
    final Color statusColor = isAvailable ? Colors.green : Colors.red;
    final String statusText = isAvailable ? l.tr('available') : l.tr('occupied');

    String locationText = l.tr('notSet');
    if (room.address != null) {
      final village = room.address!.village ?? '';
      final district = room.address!.district ?? '';
      final villageDisplay = village.isNotEmpty ? getVillageDisplay(village, isLao) : '';
      final districtDisplay = district.isNotEmpty ? getDistrictDisplay(district, isLao) : '';
      if (villageDisplay.isNotEmpty && districtDisplay.isNotEmpty) {
        locationText = '$villageDisplay, $districtDisplay';
      } else if (districtDisplay.isNotEmpty) {
        locationText = districtDisplay;
      } else if (villageDisplay.isNotEmpty) {
        locationText = villageDisplay;
      }
    }

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
                        final imgUrl = room.images![idx].fullImageUrl;
                        if (imgUrl.isEmpty) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        }
                        return CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 60, color: Colors.grey),
                      );
                    },
                  ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.9),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '\$${room.pricePerMonth.toStringAsFixed(0)}${l.tr('perMonth')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationText,
                          style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (room.owner != null)
                    Row(
                      children: [
                        Icon(Icons.person, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${l.tr('owner')}: ${room.owner!.name}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
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
                                      builder: (context) => BookRoomScreen(room: room),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable
                                ? AppColors.primary
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
                            isAvailable ? l.tr('bookNow') : l.tr('occupied'),
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
