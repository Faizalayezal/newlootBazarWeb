class CategoryModel {
  final int order;
  final String id;
  final String name;
  final String image;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.order,
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      order: json['order'] ?? 0,
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      '_id': id,
      'name': name,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}