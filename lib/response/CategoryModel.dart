class CategoryModel {
  final int order;
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.order,
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      order: json['order'] ?? 0,
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      '_id': id,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}