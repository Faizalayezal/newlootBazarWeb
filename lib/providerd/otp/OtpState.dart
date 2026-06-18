import 'package:lootbazarweb/response/UserModel.dart';

class OtpState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final UserModel? user;
  final bool isOtpResent;
  final bool isProfileCompleted;

  const OtpState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isOtpResent = false,
    this.errorMessage,
    this.user,
    this.isProfileCompleted = false,
  });

  OtpState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    UserModel? user,
    bool? isOtpResent,
    bool? isProfileCompleted,
  }) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      user: user ?? this.user,
      isOtpResent: isOtpResent ?? this.isOtpResent,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }
}
