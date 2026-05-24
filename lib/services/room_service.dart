import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/room_model.dart';
import '../models/amenity_model.dart';
import 'api_service.dart';

class RoomService {
  // Fetch all rooms (for user)
  Future<List<Room>> getAllRooms() async {
    try {
      final response = await ApiService.get('/rooms?include=images');
      if (response != null && response['data'] != null) {
        return (response['data'] as List).map((json) => Room.fromJson(json)).toList();
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
        return (response['data'] as List).map((json) => Room.fromJson(json)).toList();
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
        return (response['data'] as List).map((json) => Amenity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get amenities error: $e');
      return [];
    }
  }

  // Create a new room with images
  Future<Room?> createRoom(Room room, List<XFile> images, List<int> amenityIds) async {
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
      for (var image in images) {
        var file = await http.MultipartFile.fromPath(
          'images[]', // Array key for backend
          image.path,
        );
        multipartFiles.add(file);
      }
      
      final response = await ApiService.postMultipart('/rooms', fields, multipartFiles);
      if (response != null && response['data'] != null) {
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
    List<int> amenityIds
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
      for (var image in newImages) {
        var file = await http.MultipartFile.fromPath(
          'images[]',
          image.path,
        );
        multipartFiles.add(file);
      }
      
      final response = await ApiService.postMultipart('/rooms/$roomId', fields, multipartFiles);
      if (response != null && response['data'] != null) {
        return Room.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Update room error: $e');
      return null;
    }
  }
  
  // Example for booking a room
  Future<bool> bookRoom(int roomId, DateTime moveInDate, DateTime? moveOutDate, int totalMonths) async {
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
