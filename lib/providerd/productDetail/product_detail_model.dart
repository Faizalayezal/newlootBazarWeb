// lib/models/product_detail/product_detail_model.dart
class ProductVideo {
  final String id;
  final String video;
  final String duration;
  final int size;
  final String mimetype;
  final String filename;
  final String publicId;
  final String createdAt;

  ProductVideo({
    required this.id,
    required this.video,
    required this.duration,
    required this.size,
    required this.mimetype,
    required this.filename,
    required this.publicId,
    required this.createdAt,
  });

  factory ProductVideo.fromJson(Map<String, dynamic> json) {
    return ProductVideo(
      id: json['_id'] ?? '',
      video: json['video'] ?? '',
      duration: json['duration'] ?? '',
      size: json['size'] ?? 0,
      mimetype: json['mimetype'] ?? '',
      filename: json['filename'] ?? '',
      publicId: json['publicId'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
class ProductViewer {
  final String userId;
  final String name;
  final String address;
  final String time;
  final String phoneNumber;
  final String type;

  ProductViewer({
    required this.userId,
    required this.name,
    required this.address,
    required this.time,
    required this.phoneNumber,
    required this.type,
  });

  factory ProductViewer.fromJson(Map<String, dynamic> json) {
    return ProductViewer(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}
class ProductViewers {
  final List<ProductViewer> call;
  final List<ProductViewer> view;

  ProductViewers({
    required this.call,
    required this.view,
  });

  factory ProductViewers.fromJson(Map<String, dynamic> json) {
    return ProductViewers(
      call: (json['call'] as List?)
          ?.map((e) => ProductViewer.fromJson(e))
          .toList() ??
          [],
      view: (json['view'] as List?)
          ?.map((e) => ProductViewer.fromJson(e))
          .toList() ??
          [],
    );
  }
}
class ProductDetailImage {
  final String url;
  final String publicId;
  final String id;

  ProductDetailImage({
    required this.url,
    required this.publicId,
    required this.id,
  });

  factory ProductDetailImage.fromJson(Map<String, dynamic> json) {
    return ProductDetailImage(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
      id: json['_id'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {'_id': id, 'url': url, 'publicId': publicId};
  }
  ProductDetailImage copyWith({
    String? url,
    String? publicId,
    String? id,
  }) {
    return ProductDetailImage(
      url: url ?? this.url,
      publicId: publicId ?? this.publicId,
      id: id ?? this.id,
    );
  }
}

class ProductDetailData {
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
  final List<ProductDetailImage> images;
  final String status;
  final String createdAt;

  ProductDetailData({
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
    required this.images,
    required this.status,
    required this.createdAt,
  });

  factory ProductDetailData.fromJson(Map<String, dynamic> json) {
    return ProductDetailData(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: List<String>.from(json['category'] ?? []),
      userId: json['userId'] ?? '',
      stock: json['stock'] ?? 0,
      moq: json['moq'] ?? 0,
      location: json['location'],
      phoneNumber: json['phoneNumber'] ?? '',
      images: (json['images'] as List?)
          ?.map((e) => ProductDetailImage.fromJson(e))
          .toList() ??
          [],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] ?? '',
    );
  }
  ProductDetailData copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    List<String>? category,
    String? userId,
    int? stock,
    int? moq,
    String? location,
    String? phoneNumber,
    List<ProductDetailImage>? images,
    String? status,
    String? createdAt,
  }) {
    return ProductDetailData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      stock: stock ?? this.stock,
      moq: moq ?? this.moq,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProductDetailResponse {
  final ProductDetailData product;
  final List<ProductVideo> videos;
  final int viewsCount;
  final ProductViewers viewers;
  final List<ProductDetailData> similarProducts;

  ProductDetailResponse({
    required this.product,
    required this.videos,
    required this.viewsCount,
    required this.viewers,
    required this.similarProducts,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      product: ProductDetailData.fromJson(json['product'] ?? {}),
      videos: (json['videos'] as List?)
          ?.map((e) => ProductVideo.fromJson(e))
          .toList() ??
          [],
      viewsCount: json['viewsCount'] ?? 0,
      viewers: ProductViewers.fromJson(json['viewers'] ?? {}),
      similarProducts: (json['similarProducts'] as List?)
          ?.map((e) => ProductDetailData.fromJson(e))
          .toList() ??
          [],
    );
  }
  ProductDetailResponse copyWith({
    ProductDetailData? product,
    List<ProductVideo>? videos,
    int? viewsCount,
    ProductViewers? viewers,
    List<ProductDetailData>? similarProducts,
  }) {
    return ProductDetailResponse(
      product: product ?? this.product,
      videos: videos ?? this.videos,
      viewsCount: viewsCount ?? this.viewsCount,
      viewers: viewers ?? this.viewers,
      similarProducts: similarProducts ?? this.similarProducts,
    );
  }
}