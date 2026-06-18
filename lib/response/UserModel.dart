class UserModel {
  final String id;
  final String mobileno;
  final String? otp;
  final String? profileImage;
  final List<String> interests;
  final String? address;
  final String? name;
  final String? pincode;

  UserModel({
    required this.id,
    required this.mobileno,
    this.otp,
    this.profileImage,
    required this.interests,
    this.address,
    this.name,
    this.pincode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      mobileno: json['mobileno'] ?? '',
      otp: json['otp'],
      profileImage: json['profileImage'],
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      address: json['address'],
      name: json['name'],
      pincode: json['pincode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'mobileno': mobileno,
      'otp': otp,
      'profileImage': profileImage,
      'interests': interests,
      'address': address,
      'name': name,
      'pincode': pincode,
    };
  }
}

class VerifyOtpResponse {
  final String message;
  final UserModel user;

  VerifyOtpResponse({
    required this.message,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}