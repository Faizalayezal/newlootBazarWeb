import '../../response/register_response.dart';

class RegisterState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final RegisterResponse? data;
  final RegisterUser? userData;

  const RegisterState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.data,
    this.userData,
  });

  RegisterState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    RegisterResponse? data,
    RegisterUser? userData,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage, 
      data: data ?? this.data,
      userData: userData ?? this.userData,
    );
  }
}