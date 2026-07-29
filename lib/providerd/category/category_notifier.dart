// category_notifier.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/network_manager/repository.dart';
import 'package:lootbazarweb/providerd/category/category_state.dart';
import 'package:lootbazarweb/providerd/di/shared_prefs_provider.dart';
import 'package:lootbazarweb/utils/preferences.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';

import '../di/repository_provider.dart' show repositoryProvider;


class CategoryNotifier extends StateNotifier<CategoryState> {
  final Repository _repository;
  final SharedPrefs _prefs;

  CategoryNotifier(this._repository, this._prefs)
      : super(const CategoryState());

  /// Splash screen me call hoga
  Future<void> fetchAndCacheCategories() async {
    state = state.copyWith(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final categories = await _repository.getCategory();
      await _prefs.saveCategories(categories);
      debugPrint("API Response Count: ${categories.length}");
      state = state.copyWith(isLoading: false, isSuccess: true, data: categories);
    } catch (e) {
      // API fail -> fallback to cache
      debugPrint("-----------29: ${e.toString()}");
      final cached = await _prefs.getCategories();
      if (cached.isNotEmpty) {
        state = state.copyWith(isLoading: false, isSuccess: true, data: cached);
      } else {
        state = state.copyWith(isLoading: false, isSuccess: false, errorMessage: e.toString());
      }
    }
  }

  /// InterestsScreen me call hoga
  Future<void> loadCachedCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final categories = await _prefs.getCategories();
      debugPrint("-----------45: ${categories.length}");

      state = state.copyWith(isLoading: false, isSuccess: true, data: categories);
    } catch (e) {
      debugPrint("-----------46: ${e.toString()}");
      state = state.copyWith(isLoading: false, isSuccess: false, errorMessage: e.toString());
    }
  }

  void toggleSelection(String categoryId) {
    final selected = List<String>.from(state.selectedIds);
    if (selected.contains(categoryId)) {
      selected.remove(categoryId);
    } else {
      selected.add(categoryId);
    }
    state = state.copyWith(selectedIds: selected);
  }

  //List<String> getSelectedCategoryIds() => state.selectedIds;
  List<String> getSelectedCategoryIds(){
    final interestsJson = _prefs.getString(selectedCategory);

    final List<String> interestsValue =
    interestsJson != null && interestsJson.isNotEmpty
        ? List<String>.from(jsonDecode(interestsJson))
        : [];
    return interestsValue;
  }

  Future<void> saveCategoryOnLocal() async {
    await _prefs.setString(selectedCategory, jsonEncode(state.selectedIds));
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: []);
  }


  void reset() {
    state = const CategoryState();
  }
}


final categoryProvider =
StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final repository = ref.watch(repositoryProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  return CategoryNotifier(repository, prefs);
});