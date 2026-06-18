import 'package:image_picker/image_picker.dart';

class UpdateProfileRequest {
  final String name;
  final String address;
  final String pincode;
  final XFile? profileImage;
  final List<String> interests;

  UpdateProfileRequest({
    required this.name,
    required this.address,
    required this.pincode,
    this.profileImage,
    required this.interests,
  });
}

class UpdateProfileResponse {
  final bool success;
  final String message;

  UpdateProfileResponse({required this.success, required this.message});

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}