import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/network_manager/city_repository.dart';

class CityState {
  final List<String> cities;
  final bool isLoading;
  final String? error;

  const CityState({
    this.cities = const [],
    this.isLoading = false,
    this.error,
  });

  CityState copyWith({
    List<String>? cities,
    bool? isLoading,
    String? error,
  }) {
    return CityState(
      cities: cities ?? this.cities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CityNotifier extends StateNotifier<CityState> {
  CityNotifier() : super(const CityState());

  final CityRepository _repo = CityRepository();
  bool _loadedOnce = false;

  Future<void> loadCities({bool force = false}) async {
    if (_loadedOnce && !force) return; // cache: fetch only once
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cities = await _repo.getIndianCities();
      _loadedOnce = true;
      state = state.copyWith(cities: cities, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final cityProvider = StateNotifierProvider<CityNotifier, CityState>((ref) {
  return CityNotifier();
});