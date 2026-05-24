import 'user_model.dart';
import 'room_model.dart';

class Booking {
  final int? bookingId;
  final int? tenantId;
  final int? roomId;
  final DateTime? bookingDate;
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final int? totalMonths;
  final String bookingStatus;

  // Relationships
  final User? tenant;
  final Room? room;

  Booking({
    this.bookingId,
    this.tenantId,
    this.roomId,
    this.bookingDate,
    required this.moveInDate,
    this.moveOutDate,
    this.totalMonths,
    this.bookingStatus = 'pending',
    this.tenant,
    this.room,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id'],
      tenantId: json['tenant_id'],
      roomId: json['room_id'],
      bookingDate: json['booking_date'] != null ? DateTime.parse(json['booking_date']) : null,
      moveInDate: DateTime.parse(json['move_in_date']),
      moveOutDate: json['move_out_date'] != null ? DateTime.parse(json['move_out_date']) : null,
      totalMonths: json['total_months'],
      bookingStatus: json['booking_status'] ?? 'pending',
      tenant: json['tenant'] != null ? User.fromJson(json['tenant']) : null,
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'tenant_id': tenantId,
      'room_id': roomId,
      // Send date as YYYY-MM-DD
      'move_in_date': moveInDate.toIso8601String().split('T')[0],
      'move_out_date': moveOutDate?.toIso8601String().split('T')[0],
      'total_months': totalMonths,
      'booking_status': bookingStatus,
    };
  }
}
