import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lootbazarweb/response/CategoryModel.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._internal();

  static final SharedPrefs _instance = SharedPrefs._internal();

  factory SharedPrefs() => _instance;

  late SharedPreferences _prefs;

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> saveCategories(List<CategoryModel> categories) async {
    final jsonList = categories.map((c) => c.toJson()).toList();
    debugPrint("Saving : $jsonList");
    await _prefs.setString(categoryKey, jsonEncode(jsonList));
    debugPrint("Saved : ${_prefs.getString(categoryKey)}");
  }

  Future<List<CategoryModel>> getCategories() async {
    final jsonString = _prefs.getString(categoryKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<bool> hasCategories() async {
    return _prefs.containsKey(categoryKey);
  }

  Future<List<String>> getSearchHistory() async {
    return _prefs.getStringList(searchHistoryKey) ?? [];
  }

  Future<void> saveSearchHistory(List<String> history) async {
    await _prefs.setStringList(searchHistoryKey, history);
  }

  Future<bool> clearPrefs() => _prefs.clear();

  Future<void> clearUserPrefs() async {
    final categories = _prefs.getString(categoryKey);
    await _prefs.clear();
    if (categories != null) {
      await _prefs.setString(categoryKey, categories);
    }
  }

  Future<bool> removePrefs(String key)async => _prefs.remove(key);



}