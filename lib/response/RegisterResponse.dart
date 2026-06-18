class RegisterUser {
  final String id;
  final String mobileNo;
  final String? otp;
  final String? profileImage;
  final List<String> interests;
  final String name;
  final String address;
  final String pincode;
  final String createdAt;
  final String updatedAt;

  RegisterUser({
    required this.id,
    required this.mobileNo,
    this.otp,
    this.profileImage,
    required this.interests,
    required this.name,
    required this.address,
    required this.pincode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      id: json['_id']?.toString() ?? '',
      mobileNo: json['mobileno']?.toString() ?? '',
      otp: json['otp']?.toString(),
      profileImage: json['profileImage']?.toString(),
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'mobileno': mobileNo,
      'otp': otp,
      'profileImage': profileImage,
      'interests': interests,
      'name': name,
      'address': address,
      'pincode': pincode,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class RegisterResponse {
  final String message;
  final RegisterUser user;
  final String otp;

  RegisterResponse({
    required this.message,
    required this.user,
    required this.otp,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
      user: RegisterUser.fromJson(json['user']),
      otp: json['otp'] ?? '',
    );
  }
}