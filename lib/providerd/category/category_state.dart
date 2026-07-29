
import 'package:lootbazarweb/response/category_model.dart';

class CategoryState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<CategoryModel> data;
  final List<String> selectedIds;

  const CategoryState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.data = const [],
    this.selectedIds = const [],
  });

  CategoryState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<CategoryModel>? data,
    List<String>? selectedIds,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      data: data ?? this.data,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}