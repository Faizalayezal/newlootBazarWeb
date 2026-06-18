import 'package:flutter/foundation.dart';
import 'package:lootbazarweb/providerd/currantUserListning/current_product_model.dart';

@immutable
class CurrentProductState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final CurrentProductResponse? currantProductResponse;

  const CurrentProductState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.currantProductResponse,
  });

  CurrentProductState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    CurrentProductResponse? currantProductResponse,
  }) {
    return CurrentProductState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      currantProductResponse:
      currantProductResponse ?? this.currantProductResponse,
    );
  }
}