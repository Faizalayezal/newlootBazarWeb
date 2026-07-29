class NotificationProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final int stock;
  final int moq;
  final String location;
  final String phoneNumber;
  final String paymentStatus;
  final String status;
  final String userId;
  final List<String> categories;
  final List<String> images;
  final String createdAt;
  final String updatedAt;

  NotificationProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.moq,
    required this.location,
    required this.phoneNumber,
    required this.paymentStatus,
    required this.status,
    required this.userId,
    required this.categories,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationProduct.fromJson(Map<String, dynamic> json) {
    return NotificationProduct(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      moq: (json['moq'] as num?)?.toInt() ?? 0,
      location: json['location']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      categories: (json['category'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      images: (json['images'] as List?)
          ?.map((e) => e['url'].toString())
          .toList() ??
          [],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

class NotificationViewer {
  final String id;
  final String name;
  final String mobileNo;
  final String address;
  final String pincode;
  final String profileImage;
  final List<String> interests;
  final String createdAt;
  final String updatedAt;

  NotificationViewer({
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.address,
    required this.pincode,
    required this.profileImage,
    required this.interests,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationViewer.fromJson(Map<String, dynamic> json) {
    return NotificationViewer(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobileNo: json['mobileno']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      profileImage: json['profileImage']?.toString() ?? '',
      interests: (json['interests'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

class NotificationModel {
  final String id;
  final NotificationProduct product;
  final NotificationViewer viewer;
  final bool isRead;
  final String type;
  final String viewedAt;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.id,
    required this.product,
    required this.viewer,
    required this.isRead,
    required this.type,
    required this.viewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      product: NotificationProduct.fromJson(
        (json['productId'] ?? {}) as Map<String, dynamic>,
      ),
      viewer: NotificationViewer.fromJson(
        (json['viewerUserId'] ?? {}) as Map<String, dynamic>,
      ),
      isRead: json['isRead'] ?? false,
      type: json['type']?.toString() ?? '',
      viewedAt: json['viewedAt']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      product: product,
      viewer: viewer,
      isRead: isRead ?? this.isRead,
      type: type,
      viewedAt: viewedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}