import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import '../models/room_model.dart';
import '../models/amenity_model.dart';
import 'api_service.dart';

class RoomService {
  /// Compress an image file to JPEG, max 1920×1920, quality 80.
  /// Returns compressed bytes, or the original bytes if compression fails.
  static Future<List<int>> _compressImage(XFile image) async {
    try {
      Uint8List? result;
      if (image.path.startsWith('/') && image.path.length > 1) {
        result = await FlutterImageCompress.compressWithFile(
          image.path,
          minWidth: 1920,
          minHeight: 1920,
          quality: 80,
          format: CompressFormat.jpeg,
        );
      } else {
        final bytes = await image.readAsBytes();
        result = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 1920,
          minHeight: 1920,
          quality: 80,
          format: CompressFormat.jpeg,
        );
      }
      if (result != null && result.isNotEmpty) {
        debugPrint(
          'RoomService: compressed ${p.basename(image.path)} '
          '→ ${result.length} bytes',
        );
        return result;
      }
    } catch (e) {
      debugPrint('RoomService: compression failed for ${image.path}: $e');
    }
    // Fallback: return original bytes
    return await image.readAsBytes();
  }

  // Fetch all rooms (for user)
  Future<List<Room>> getAllRooms() async {
    try {
      final response = await ApiService.get('/rooms?include=images');
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Room.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get rooms error: $e');
      return [];
    }
  }

  // Fetch rooms owned by the current owner
  Future<List<Room>> getMyRooms() async {
    try {
      final response = await ApiService.get('/owner/rooms?include=images');
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Room.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get my rooms error: $e');
      return [];
    }
  }

  // Fetch all available amenities
  Future<List<Amenity>> getAmenities() async {
    try {
      final response = await ApiService.get('/amenities');
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Amenity.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get amenities error: $e');
      return [];
    }
  }

  // Create a new room with images
  Future<Room?> createRoom(
    Room room,
    List<XFile> images,
    List<int> amenityIds,
  ) async {
    try {
      final Map<String, String> fields = {
        'room_name': room.roomName,
        'price_per_month': room.pricePerMonth.toString(),
        'description': room.description ?? '',
        'village': room.address?.village ?? '',
        'district': room.address?.district ?? '',
        'province': room.address?.province ?? 'Vientiane',
      };

      // Add amenities
      for (int i = 0; i < amenityIds.length; i++) {
        fields['amenities[$i]'] = amenityIds[i].toString();
      }

      List<http.MultipartFile> multipartFiles = [];
      for (int idx = 0; idx < images.length; idx++) {
        final image = images[idx];
        final compressed = await _compressImage(image);
        // Use .jpg extension since we always compress to JPEG
        final rawName = p.basename(image.path);
        final filename = rawName.isNotEmpty
            ? '${p.basenameWithoutExtension(rawName)}.jpg'
            : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final file = http.MultipartFile.fromBytes(
          'images[]',
          compressed,
          filename: filename,
        );
        debugPrint(
          'RoomService: attaching compressed file '
          '-> field=images[] name=$filename size=${compressed.length}',
        );
        multipartFiles.add(file);
      }

      final response = await ApiService.postMultipart(
        '/rooms',
        fields,
        multipartFiles,
      );
      if (response != null && response['data'] != null) {
        // Check if server returned images; if not, try fetching the room again
        try {
          final data = response['data'] as Map<String, dynamic>;
          final images = data['images'] as List<dynamic>?;
          if (images == null || images.isEmpty) {
            final roomId = data['room_id'] ?? data['id'];
            debugPrint(
              'RoomService: createRoom response contains no images. Trying to fetch room/$roomId',
            );
            if (roomId != null) {
              try {
                final fresh = await ApiService.get(
                  '/rooms/$roomId?include=images',
                );
                if (fresh != null && fresh['data'] != null) {
                  return Room.fromJson(fresh['data']);
                }
              } catch (e) {
                debugPrint('RoomService: failed to fetch room/$roomId: $e');
              }
            }
          }
        } catch (e) {
          debugPrint(
            'RoomService: error while parsing create response images: $e',
          );
        }

        return Room.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Create room error: $e');
      return null;
    }
  }

  // Update an existing room
  Future<Room?> updateRoom(
    int roomId,
    Room room,
    List<XFile> newImages,
    List<String> removedImageUrls,
    List<int> amenityIds,
  ) async {
    try {
      final Map<String, String> fields = {
        '_method': 'PUT', // Laravel method spoofing for multipart
        'room_name': room.roomName,
        'price_per_month': room.pricePerMonth.toString(),
        'description': room.description ?? '',
        'village': room.address?.village ?? '',
        'district': room.address?.district ?? '',
        'province': room.address?.province ?? 'Vientiane',
      };

      // Add amenities
      for (int i = 0; i < amenityIds.length; i++) {
        fields['amenities[$i]'] = amenityIds[i].toString();
      }

      // Add removed images if any
      if (removedImageUrls.isNotEmpty) {
        for (int i = 0; i < removedImageUrls.length; i++) {
          // Extract the filename from the URL
          final String url = removedImageUrls[i];
          final String fileName = url.split('/').last;
          fields['removed_images[$i]'] = fileName;
        }
      }

      List<http.MultipartFile> multipartFiles = [];
      for (int idx = 0; idx < newImages.length; idx++) {
        final image = newImages[idx];
        final compressed = await _compressImage(image);
        final rawName = p.basename(image.path);
        final filename = rawName.isNotEmpty
            ? '${p.basenameWithoutExtension(rawName)}.jpg'
            : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final file = http.MultipartFile.fromBytes(
          'images[]',
          compressed,
          filename: filename,
        );
        debugPrint(
          'RoomService: attaching compressed new file '
          '-> field=images[] name=$filename size=${compressed.length}',
        );
        multipartFiles.add(file);
      }

      final response = await ApiService.postMultipart(
        '/rooms/$roomId',
        fields,
        multipartFiles,
      );
      if (response != null && response['data'] != null) {
        // If server didn't return images, try fetching room by id again
        try {
          final data = response['data'] as Map<String, dynamic>;
          final images = data['images'] as List<dynamic>?;
          if (images == null || images.isEmpty) {
            final fetchedId = data['room_id'] ?? data['id'] ?? roomId;
            debugPrint(
              'RoomService: updateRoom response contains no images. Trying to fetch room/$fetchedId',
            );
            try {
              final fresh = await ApiService.get(
                '/rooms/$fetchedId?include=images',
              );
              if (fresh != null && fresh['data'] != null) {
                return Room.fromJson(fresh['data']);
              }
            } catch (e) {
              debugPrint('RoomService: failed to fetch room/$fetchedId: $e');
            }
          }
        } catch (e) {
          debugPrint(
            'RoomService: error while parsing update response images: $e',
          );
        }

        return Room.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Update room error: $e');
      return null;
    }
  }

  Future<bool> requestDeletion(int roomId) async {
    try {
      await ApiService.patch('/rooms/$roomId/request-delete', {});
      return true;
    } catch (e) {
      debugPrint('Request deletion error: $e');
      rethrow;
    }
  }

  // Example for booking a room
  Future<bool> bookRoom(
    int roomId,
    DateTime moveInDate,
    DateTime? moveOutDate,
    int totalMonths,
  ) async {
    try {
      final response = await ApiService.post('/bookings', {
        'room_id': roomId,
        'move_in_date': moveInDate.toIso8601String().split('T')[0],
        'move_out_date': moveOutDate?.toIso8601String().split('T')[0],
        'total_months': totalMonths,
      });
      return response != null;
    } catch (e) {
      print('Booking error: $e');
      return false;
    }
  }

  // Fetch bookings for owner's rooms
  Future<List<dynamic>> getOwnerBookings() async {
    try {
      final response = await ApiService.get('/owner/bookings');
      if (response != null && response['data'] != null) {
        return response['data'] as List;
      }
      return [];
    } catch (e) {
      print('Get owner bookings error: $e');
      return [];
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
      final response = await ApiService.post('/bookings/$bookingId/status', {
        'status': status,
        '_method': 'PATCH',
      });
      return response != null;
    } catch (e) {
      print('Update booking status error: $e');
      return false;
    }
  }
}
