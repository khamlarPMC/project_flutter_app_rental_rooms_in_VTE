import 'user_model.dart';
import 'address_model.dart';
import 'room_image_model.dart';
import 'amenity_model.dart';

class Room {
  final int? roomId;
  final int? ownerId;
  final String roomName;
  final double pricePerMonth;
  final String? description;
  final String roomStatus;
  final int? addressId;
  final DateTime? createdAt;
  final bool isApproved;

  // Relationships
  final User? owner;
  final Address? address;
  final List<RoomImage>? images;
  final List<Amenity>? amenities;

  Room({
    this.roomId,
    this.ownerId,
    required this.roomName,
    required this.pricePerMonth,
    this.description,
    this.roomStatus = 'available',
    this.addressId,
    this.createdAt,
    this.isApproved = false,
    this.owner,
    this.address,
    this.images,
    this.amenities,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['room_id'],
      ownerId: json['owner_id'],
      roomName: json['room_name'] ?? '',
      pricePerMonth: json['price_per_month'] != null 
          ? double.parse(json['price_per_month'].toString()) 
          : 0.0,
      description: json['description'],
      roomStatus: json['room_status'] ?? 'available',
      addressId: json['address_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      isApproved: json['is_approved'] == 1 || json['is_approved'] == true,
      
      // Parse relationships if they exist in the JSON response
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      images: (json['images'] ?? json['room_images'] ?? json['photos']) != null 
          ? ((json['images'] ?? json['room_images'] ?? json['photos']) as List)
              .map((i) => RoomImage.fromJson(i))
              .toList()
          : (json['image_path'] != null || json['photo'] != null)
              ? [RoomImage(imageUrl: json['image_path'] ?? json['photo'] ?? '')]
              : null,
      amenities: json['amenities'] != null 
          ? (json['amenities'] as List).map((i) => Amenity.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'owner_id': ownerId,
      'room_name': roomName,
      'price_per_month': pricePerMonth,
      'description': description,
      'room_status': roomStatus,
      'address_id': addressId,
      'is_approved': isApproved,
    };
  }
}
