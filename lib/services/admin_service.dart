import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/booking_model.dart';
import 'api_service.dart';

class AdminService {
  // Users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await ApiService.get('/admin/users');
      if (response != null && response['data'] != null) {
        return (response['data'] as List).map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await ApiService.delete('/admin/users/$id');
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Rooms
  Future<List<Room>> getAllRooms() async {
    try {
      final response = await ApiService.get('/admin/rooms');
      if (response != null && response['data'] != null) {
        return (response['data'] as List).map((json) => Room.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching rooms: $e');
      return [];
    }
  }

  Future<bool> deleteRoom(int id) async {
    try {
      await ApiService.delete('/admin/rooms/$id');
      return true;
    } catch (e) {
      print('Error deleting room: $e');
      return false;
    }
  }

  Future<bool> approveRoom(int id) async {
    try {
      await ApiService.patch('/admin/rooms/$id/approve', {});
      return true;
    } catch (e) {
      print('Error approving room: $e');
      return false;
    }
  }

  Future<bool> confirmDeleteRoom(int id) async {
    try {
      await ApiService.delete('/admin/rooms/$id');
      return true;
    } catch (e) {
      print('Error confirming room deletion: $e');
      return false;
    }
  }

  Future<bool> rejectDeletion(int id) async {
    try {
      await ApiService.patch('/admin/rooms/$id/reject-delete', {});
      return true;
    } catch (e) {
      debugPrint('Error rejecting deletion: $e');
      rethrow;
    }
  }

  // Bookings
  Future<List<Booking>> getAllBookings() async {
    try {
      final response = await ApiService.get('/admin/bookings');
      if (response != null && response['data'] != null) {
        return (response['data'] as List).map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  Future<bool> cancelBooking(int id) async {
    try {
      await ApiService.patch('/admin/bookings/$id/cancel', {});
      return true;
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  Future<bool> deleteBooking(int id) async {
    try {
      await ApiService.delete('/admin/bookings/$id');
      return true;
    } catch (e) {
      print('Error deleting booking: $e');
      return false;
    }
  }

  // Reports
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await ApiService.get('/admin/stats');
      if (response != null && response['data'] != null) {
        return response['data'];
      }
      return {
        'total_users': 0,
        'total_rooms': 0,
        'total_bookings': 0,
        'total_revenue': 0.0,
      };
    } catch (e) {
      print('Error fetching stats: $e');
      return {
        'total_users': 0,
        'total_rooms': 0,
        'total_bookings': 0,
        'total_revenue': 0.0,
      };
    }
  }
}
