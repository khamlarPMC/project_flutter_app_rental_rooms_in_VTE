import '../models/booking_model.dart';
import 'api_service.dart';

class BookingService {
  Future<List<Booking>> getUserBookings() async {
    try {
      final response = await ApiService.get('/bookings');
      if (response['success'] == true) {
        List<dynamic> data = response['data'];
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user bookings: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      final response = await ApiService.patch('/bookings/$bookingId/cancel', {});
      return response;
    } catch (e) {
      print('Error cancelling booking: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBooking(int bookingId, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('/bookings/$bookingId', data);
      return response;
    } catch (e) {
      print('Error updating booking: $e');
      rethrow;
    }
  }
}
