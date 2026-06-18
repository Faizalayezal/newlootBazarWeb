// lib/providerd/notification/notification_model.dart

class NotificationProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String status;
  final List<String> images;

  NotificationProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.status,
    required this.images,
  });

  factory NotificationProduct.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List? ?? [];
    return NotificationProduct(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      images: rawImages
          .map((e) => (e['url'] ?? '') as String)
          .where((url) => url.isNotEmpty)
          .toList(),
    );
  }
}

class NotificationViewer {
  final String id;
  final String name;
  final String address;
  final String pincode;
  final String? profileImage;

  NotificationViewer({
    required this.id,
    required this.name,
    required this.address,
    required this.pincode,
    this.profileImage,
  });

  factory NotificationViewer.fromJson(Map<String, dynamic> json) {
    return NotificationViewer(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      pincode: json['pincode'] ?? '',
      profileImage: json['profileImage'],
    );
  }
}

class NotificationModel {
  final String id;
  final NotificationProduct product;
  final NotificationViewer viewer;
  final bool isRead;
  final String type; // 'view' or 'call'
  final String viewedAt;

  NotificationModel({
    required this.id,
    required this.product,
    required this.viewer,
    required this.isRead,
    required this.type,
    required this.viewedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      product: NotificationProduct.fromJson(
          json['productId'] as Map<String, dynamic>? ?? {}),
      viewer: NotificationViewer.fromJson(
          json['viewerUserId'] as Map<String, dynamic>? ?? {}),
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? 'view',
      viewedAt: json['viewedAt'] ?? '',
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      product: product,
      viewer: viewer,
      isRead: isRead ?? this.isRead,
      type: type,
      viewedAt: viewedAt,
    );
  }
}