import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lootbazarweb/network_manager/repository.dart';
import 'package:lootbazarweb/providerd/di/repositoryProvider.dart';
import 'package:lootbazarweb/providerd/di/sharedPrefsProvider.dart';
import 'package:lootbazarweb/providerd/register/register_state.dart';
import 'package:lootbazarweb/response/requestion_response/UpdateProfileRequest.dart';
import 'package:lootbazarweb/utils/preferences.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';

class RegisterNotifier extends StateNotifier<RegisterState> {
  final Repository _repository;
  final SharedPrefs _prefs;

  RegisterNotifier(this._repository, this._prefs)
    : super(const RegisterState());

  Future<void> register({required String mobileNo}) async {
    // Reset error, start loading
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );

    try {
      final response = await _repository.register(mobileNo: mobileNo);

      await _prefs.setString(phoneNumber, mobileNo);

      state = state.copyWith(isLoading: false, isSuccess: true, data: response);
    } catch (e, s) {
      debugPrint('Error during registration---36: $e');
      debugPrint('Stack trace---37: $s');
      
      String message = e.toString().replaceAll('Exception: ', '');
      
      // Handle specific technical error messages
      if (message.contains('mobileno') && message.contains('invalid')) {
        message = 'Invalid mobile number. Please check and try again.';
      }

      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: message,
      );
    }
  }

  Future<void> localStore({
    String? userIdSet,
    required String userName,
    required String userAddress,
    required String userPinCode,
    required String userImage,
    String? categories,
    String? userPhonNumber,
  }) async {
    try {
      if (userIdSet != null) {
        await _prefs.setString(userId, userIdSet);
      }
      if (userPhonNumber != null) {
        await _prefs.setString(phoneNumber, userPhonNumber);
      }

      if (userName != null) {
        await _prefs.setString(name, userName);
      }

      if (userAddress != null) {
        await _prefs.setString(address, userAddress);
      }

      if (userPinCode != null) {
        await _prefs.setString(pincode, userPinCode);
      }

      if (userImage != null) {
        await _prefs.setString(profileImage, userImage);
      }

      if (categories != null) {
        await _prefs.setString(selectedCategory, jsonEncode(categories));
      }
    } catch (e) {
      print("$e");
    }
  }

  Future<bool> getUserData() async {
    try {
      final isProfileCompleted =
          await (_prefs.getString(userId)?.isNotEmpty ?? false) &&
         // (_prefs.getString(profileImage)?.isNotEmpty ?? false) &&
          (_prefs.getString(address)?.isNotEmpty ?? false) &&
          (_prefs.getString(name)?.isNotEmpty ?? false) &&
          (_prefs.getString(pincode)?.isNotEmpty ?? false) &&
          (_prefs.getString(selectedCategory)?.isNotEmpty ?? false);
      debugPrint("-----------72: ${_prefs.getString(selectedCategory)}");
      debugPrint("-----------73: ${_prefs.getString(userId)}");
      debugPrint("-----------74: ${_prefs.getString(address)}");
      debugPrint("-----------75: ${_prefs.getString(name)}");
      debugPrint("-----------76: ${_prefs.getString(pincode)}");

      return isProfileCompleted;
    } catch (e) {
      debugPrint("-----------46: ${e.toString()}");
      return false;
    }
  }

  Future<void> syncProfile() async {
    try {
      final userIdValue = _prefs.getString(userId);
      if (userIdValue == null || userIdValue.isEmpty) return;

      final data = await _repository.getProfile(userId: userIdValue);

      await _prefs.setString(name, data['name'] ?? '');
      await _prefs.setString(address, data['address'] ?? '');
      await _prefs.setString(pincode, data['pincode'] ?? '');
      await _prefs.setString(profileImage, data['profileImage'] ?? '');
      await _prefs.setString(phoneNumber, data['mobileno'] ?? '');
      await _prefs.setString(razorpayKey, data['apiKey'] ?? '');
      await _prefs.setString(listingAmount, (data['amount'] ?? 0).toString());

      if (data['interests'] != null) {
        final List<String> interestIds = (data['interests'] as List)
            .map((i) => i['_id'].toString())
            .toList();
        await _prefs.setString(selectedCategory, jsonEncode(interestIds));
      }
    } catch (e) {
      debugPrint("Sync Profile Error: $e");
    }
  }

  Future<void> updateProfile({
    String? newName,
    String? newAddress,
    String? newPincode,
    XFile? newImage,
  }) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );

    try {
      final userIdValue = _prefs.getString(userId) ?? "";
      
      // Use passed values or fall back to current local values
      final nameValue = newName ?? _prefs.getString(name) ?? "";
      final addressValue = newAddress ?? _prefs.getString(address) ?? "";
      final pincodeValue = newPincode ?? _prefs.getString(pincode) ?? "";
      
      final interestsJson = _prefs.getString(selectedCategory);
      final List<String> interestsValue =
          interestsJson != null && interestsJson.isNotEmpty
          ? List<String>.from(jsonDecode(interestsJson))
          : [];

      final currentImagePath = _prefs.getString(profileImage) ?? "";
      final bool isLocalFile = currentImagePath.isNotEmpty &&
          !currentImagePath.startsWith('http') &&
          !currentImagePath.startsWith('https');

      final image = newImage ?? (isLocalFile ? XFile(currentImagePath) : null);

      final request = UpdateProfileRequest(
        name: nameValue,
        address: addressValue,
        pincode: pincodeValue,
        interests: interestsValue,
        profileImage: image,
      );

      final response = await _repository.updateProfile(
        userId: userIdValue,
        request: request,
      );

      // Store in local only AFTER successful API response
      await localStore(
        userIdSet: response.id,
        userName: response.name,
        userAddress: response.address,
        userPinCode: response.pincode,
        userImage: response.profileImage ?? '',
        userPhonNumber: response.mobileNo ?? '',
        categories: jsonEncode(response.interests),
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        userData: response,
      );
    } catch (e) {
      String message = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: message,
      );
    }
  }

  void reset() {
    state = const RegisterState();
  }
}

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) {
    final repository = ref.watch(repositoryProvider);
    final prefs = ref.watch(sharedPrefsProvider);
    return RegisterNotifier(repository, prefs);
  },
);
