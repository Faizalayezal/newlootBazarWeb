class StoreProductRequest {
  final String title;
  final String description;
  final double price;
  final int stock;
  final int moq;
  final List<String> category;
  final String userId;
  final String phoneNumber;
  final String location;
  final List<String> imagePaths;

  StoreProductRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.moq,
    required this.category,
    required this.userId,
    required this.phoneNumber,
    required this.location,
    required this.imagePaths,
  });
}