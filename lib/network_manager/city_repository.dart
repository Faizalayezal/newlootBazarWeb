import 'package:dio/dio.dart';
import 'package:lootbazarweb/constant/api_constants.dart';
import 'package:lootbazarweb/response/CityModel.dart';

class CityRepository {
  // Plain Dio instance — intentionally NOT using DioClient(),
  // since this third-party API doesn't need our x-api-key / interceptors.
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  /// Fetches all cities from countriesnow API and returns
  /// only India's cities, deduped & sorted alphabetically.
  Future<List<String>> getIndianCities() async {
    try {
      final response = await _dio.get(ApiConstants.citiesPopulation);
      final data = response.data;

      if (data is! Map<String, dynamic> || data['data'] == null) {
        return [];
      }

      final List<dynamic> rawList = data['data'];

      final List<CityModel> allCities =
      rawList.map((e) => CityModel.fromJson(e)).toList();

      final Set<String> indiaCities = allCities
          .where((c) => c.country.trim().toLowerCase() == 'india')
          .map((c) => c.city.trim())
          .where((c) => c.isNotEmpty)
          .toSet();

      final list = indiaCities.toList()..sort();
      return list;
    } on DioException catch (e) {
      throw Exception('Failed to load cities: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load cities: $e');
    }
  }
}