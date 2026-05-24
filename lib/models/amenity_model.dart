class Amenity {
  final int? amenityId;
  final String? amenityName;

  Amenity({this.amenityId, this.amenityName});

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      amenityId: json['amenity_id'],
      amenityName: json['amenity_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'amenity_id': amenityId, 'amenity_name': amenityName};
  }
}
