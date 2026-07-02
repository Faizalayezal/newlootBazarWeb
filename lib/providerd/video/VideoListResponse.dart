// lib/models/video_model.dart

class VideoListResponse {
  final List<VideoItem> videos;

  VideoListResponse({required this.videos});

  factory VideoListResponse.fromJson(List<dynamic> json) {
    return VideoListResponse(
      videos: json
          .map((v) => VideoItem.fromJson(v))
          .where((v) => v.video.isNotEmpty)
          .toList(),
    );
  }
}

class VideoItem {
  final String id;
  final String video;
  final String duration;
  final String filename;
  final String expiresAt;
  final String createdAt;
  final VideoUser? user;
  final VideoProduct? product;

  VideoItem({
    required this.id,
    required this.video,
    required this.duration,
    required this.filename,
    required this.expiresAt,
    required this.createdAt,
    this.user,
    this.product,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['_id'] ?? '',
      video: json['video'] ?? '',
      duration: json['duration']?.toString() ?? '0',
      filename: json['filename'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
      user: json['userId'] is Map
          ? VideoUser.fromJson(json['userId'])
          : null,
      product: json['productId'] is Map
          ? VideoProduct.fromJson(json['productId'])
          : null,
    );
  }

  // Duration seconds for story player
  int get durationSeconds {
    final d = double.tryParse(duration) ?? 5.0;
    return d.ceil().clamp(3, 60);
  }
}

class VideoUser {
  final String id;
  final String name;
  final String mobileno;
  final String profileImage;

  VideoUser({
    required this.id,
    required this.name,
    required this.mobileno,
    required this.profileImage,
  });

  factory VideoUser.fromJson(Map<String, dynamic> json) {
    return VideoUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobileno: json['mobileno'] ?? '',
      profileImage: json['profileImage'] ?? '',
    );
  }
}

class VideoProduct {
  final String id;
  final String title;
  final String location;
  final String description;
  final num price;
  final num stock;
  final num moq;
  final List<String> imageUrls;

  VideoProduct({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.price,
    required this.stock,
    required this.moq,
    required this.imageUrls,
  });

  factory VideoProduct.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List? ?? [];

    final urls = rawImages.map((img) {
      if (img is! Map) return '';

      // Normal case: img['url'] directly available
      final directUrl = img['url'];
      if (directUrl is String && directUrl.startsWith('http')) {
        return directUrl;
      }

      // Backend bug case: {"0":"h","1":"t",...} — string indexed as map
      // Reconstruct string from numeric keys
      final keys = img.keys
          .where((k) => int.tryParse(k.toString()) != null)
          .map((k) => int.parse(k.toString()))
          .toList()
        ..sort();

      if (keys.isEmpty) return '';

      final reconstructed = keys.map((k) => img[k.toString()]).join();
      return reconstructed.startsWith('http') ? reconstructed : '';
    }).where((url) => url.isNotEmpty).toList();

    return VideoProduct(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      stock: json['stock'] ?? '',
      moq: json['moq'] ?? '',
      imageUrls: urls,
    );
  }
}