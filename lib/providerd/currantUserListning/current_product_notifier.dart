import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/providerd/currantUserListning/current_product_state.dart';
import 'package:lootbazarweb/providerd/di/repository_provider.dart';
import 'package:lootbazarweb/providerd/di/shared_prefs_provider.dart';
import 'package:lootbazarweb/utils/preferences.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';
import '../../network_manager/repository.dart';

class CurrentProductNotifier extends StateNotifier<CurrentProductState> {
  final Repository _repository;
  final SharedPrefs _prefs;

  CurrentProductNotifier(this._repository, this._prefs)
    : super(const CurrentProductState());

  Future<void> getCurrentUserProducts() async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );
    try {
      var getUserId = _prefs.getString(userId);
      final response = await _repository.getCurrentUserProducts(
        userId: getUserId ?? '',
      );
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        currantProductResponse: response,
      );
    } catch (e) {
      debugPrint("--------33: ${e.toString()}");
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await getCurrentUserProducts();
  }
}

final currentProductProvider =
    StateNotifierProvider<CurrentProductNotifier, CurrentProductState>((ref) {
      final repository = ref.watch(repositoryProvider);
      final prefs = ref.watch(sharedPrefsProvider);
      return CurrentProductNotifier(repository, prefs);
    });
