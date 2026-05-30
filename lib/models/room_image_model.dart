import 'package:app_rental_room/utils/app_constants.dart';

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
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return '';
    }

    if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
      // If the backend returns a URL containing localhost or 127.0.0.1, we must replace it
      // with AppApi.host (which resolves to 10.0.2.2 on Android emulator) so the app can load it.
      if (trimmedUrl.contains('://localhost:') ||
          trimmedUrl.contains('://127.0.0.1:')) {
        final uri = Uri.parse(trimmedUrl);
        final pathAndQuery = trimmedUrl.substring(
          trimmedUrl.indexOf(uri.host) +
              uri.host.length +
              (uri.hasPort ? ':${uri.port}'.length : 0),
        );
        return '${AppApi.host}$pathAndQuery';
      }
      if (trimmedUrl.contains('://localhost') ||
          trimmedUrl.contains('://127.0.0.1')) {
        final uri = Uri.parse(trimmedUrl);
        final pathAndQuery = trimmedUrl.substring(
          trimmedUrl.indexOf(uri.host) + uri.host.length,
        );
        return '${AppApi.host}$pathAndQuery';
      }
      return trimmedUrl;
    }

    var path = trimmedUrl;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (path.startsWith('storage/')) {
      return '${AppApi.host}/$path';
    }

    return '${AppApi.host}/storage/$path';
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
