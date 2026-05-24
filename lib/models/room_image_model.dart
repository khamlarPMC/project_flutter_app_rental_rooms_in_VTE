class RoomImage {
  final int? imageId;
  final String imageUrl;
  final int? roomId;
  final bool isMain;

  RoomImage({
    this.imageId,
    required this.imageUrl,
    this.roomId,
    this.isMain = false,
  });

  factory RoomImage.fromJson(Map<String, dynamic> json) {
    return RoomImage(
      imageId: json['image_id'] ?? json['id'],
      imageUrl: json['image_url'] ?? json['path'] ?? json['image'] ?? '',
      roomId: json['room_id'],
      isMain: json['is_main'] == 1 || json['is_main'] == true,
    );
  }

  String get fullImageUrl {
    if (imageUrl.startsWith('http')) {
      print('🖼️ [IMAGE URL - full] $imageUrl');
      return imageUrl;
    }
    final url = 'http://10.0.2.2:8000/storage/$imageUrl';
    print('🖼️ [IMAGE URL - built] $url');
    return url;
  }

  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'image_url': imageUrl,
      'room_id': roomId,
      'is_main': isMain ? 1 : 0,
    };
  }
}
