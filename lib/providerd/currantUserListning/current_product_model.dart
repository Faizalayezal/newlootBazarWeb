class CurrentProductImage {
  final String url;
  final String publicId;
  final String id;

  CurrentProductImage({
    required this.url,
    required this.publicId,
    required this.id,
  });

  factory CurrentProductImage.fromJson(Map<String, dynamic> json) {
    return CurrentProductImage(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}

class CurrentProductData {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> category;
  final String userId;
  final int stock;
  final int moq;
  final String? location;
  final String phoneNumber;
  final String paymentStatus;
  final List<CurrentProductImage> images;
  final String status;
  final String createdAt;

  CurrentProductData({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.userId,
    required this.stock,
    required this.moq,
    this.location,
    required this.phoneNumber,
    required this.paymentStatus,
    required this.images,
    required this.status,
    required this.createdAt,
  });

  factory CurrentProductData.fromJson(Map<String, dynamic> json) {
    return CurrentProductData(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: List<String>.from(json['category'] ?? []),
      userId: json['userId'] ?? '',
      stock: json['stock'] ?? 0,
      moq: json['moq'] ?? 0,
      location: json['location'],
      phoneNumber: json['phoneNumber'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => CurrentProductImage.fromJson(e))
          .toList() ??
          [],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] ?? '',
    );
  }

  String get firstImageUrl => images.isNotEmpty ? images.first.url : '';
}

class CurrentProductResponse {
  final List<CurrentProductData> currantProductData;

  CurrentProductResponse({required this.currantProductData});

  factory CurrentProductResponse.fromJson(List<dynamic> json) {
    return CurrentProductResponse(
      currantProductData:
      json.map((e) => CurrentProductData.fromJson(e)).toList(),
    );
  }
}