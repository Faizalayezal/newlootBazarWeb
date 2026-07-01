import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/network_manager/repository.dart';
import 'package:lootbazarweb/providerd/otp/OtpState.dart';
import 'package:lootbazarweb/providerd/di/sharedPrefsProvider.dart';
import 'package:lootbazarweb/utils/preferences.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';
import '../di/repositoryProvider.dart' show repositoryProvider;

class OtpNotifier extends StateNotifier<OtpState> {
  final Repository _repository;
  final SharedPrefs _prefs;

  OtpNotifier(this._repository, this._prefs) : super(const OtpState());

  Future<void> verifyOtp({
    required String mobileNo,
    required String otp,
  }) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );
    try {
      final response = await _repository.verifyOtp(
        mobileNo: mobileNo,
        otp: otp,
      );
      final isProfileCompleted =
          (response.user.id.trim().isNotEmpty ?? false) &&
          (response.user.name?.trim().isNotEmpty ?? false) &&
          (response.user.mobileno.trim().isNotEmpty ?? false) &&
          (response.user.address?.trim().isNotEmpty ?? false) &&
          (response.user.pincode?.trim().isNotEmpty ?? false) &&
          (response.user.interests?.isNotEmpty ?? false);// &&
          //(response.user.profileImage?.trim().isNotEmpty ?? false);

      await _prefs.setString(userId, response.user.id);
      await _prefs.setString(name, response.user.name ?? '');
      await _prefs.setString(address, response.user.address ?? '');
      await _prefs.setString(pincode, response.user.pincode ?? '');
      await _prefs.setString(phoneNumber, response.user.mobileno ?? '');
      await _prefs.setString(
        selectedCategory,
        jsonEncode(response.user.interests ?? ''),
      );
      await _prefs.setString(profileImage, response.user.profileImage ?? '');

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        user: response.user,
        isProfileCompleted: isProfileCompleted,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> requestOtp() async {
    state = state.copyWith(
      isLoading: true,
      isOtpResent: false,
      errorMessage: null,
    );
    final mobileNo = _prefs.getString(phoneNumber) ?? '';
    try {
      if (mobileNo == null || mobileNo.isEmpty) {
        debugPrint("Mobile number not found");
        return;
      }
      await _repository.register(mobileNo: mobileNo);

      state = state.copyWith(isLoading: false, isOtpResent: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isOtpResent: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const OtpState();
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  final repository = ref.watch(repositoryProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  return OtpNotifier(repository, prefs);
});
