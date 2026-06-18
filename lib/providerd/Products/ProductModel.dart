import 'package:lootbazarweb/providerd/productDetail/product_detail_model.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final num price;
  final List<String> category;
  final String userId;
  final int stock;
  final int moq;
  final String phoneNumber;
  final String? location;
  final List<ProductDetailImage> images;
  final String createdAt;
  final String updatedAt;
  final String status;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.userId,
    required this.stock,
    required this.moq,
    required this.phoneNumber,
    required this.images,
    required this.createdAt,
    required this.location,
    required this.updatedAt,
    required this.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      price: json['price'] ?? 0,
      category:
          (json['category'] as List?)?.map((e) => e.toString()).toList() ?? [],
      userId: json['userId'] ?? '',
      stock: json['stock'] ?? 0,
      moq: json['moq'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      images:
          (json['images'] as List?)
              ?.map((e) => ProductDetailImage.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'userId': userId,
      'location': location,
      'stock': stock,
      'moq': moq,
      'phoneNumber': phoneNumber,
      'images': images.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
    };
  }
}

class ProductListResponse {
  final int currentPage;
  final int totalPages;
  final int totalProducts;
  final List<ProductModel> products;

  ProductListResponse({
    required this.currentPage,
    required this.totalPages,
    required this.totalProducts,
    required this.products,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalProducts: json['totalProducts'] ?? 0,
      products: json['products'] != null
          ? List<ProductModel>.from(
              json['products'].map((e) => ProductModel.fromJson(e)),
            )
          : [],
    );
  }
}
