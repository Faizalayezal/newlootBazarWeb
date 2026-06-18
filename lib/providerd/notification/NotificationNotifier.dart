// lib/providerd/notification/notification_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/providerd/di/repositoryProvider.dart';
import 'package:lootbazarweb/providerd/di/sharedPrefsProvider.dart';
import 'package:lootbazarweb/providerd/notification/NotificationState.dart';
import 'package:lootbazarweb/utils/preferences.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';
import '../../network_manager/repository.dart';

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Repository _repository;
  final SharedPrefs _prefs;

  NotificationNotifier(this._repository, this._prefs)
      : super(const NotificationState());

  Future<void> getNotifications() async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );
    try {
      final currentUserId = await _prefs.getString(userId);
      if (currentUserId == null || currentUserId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          notifications: [],
          unreadCount: 0,
        );
        return;
      }

      final list = await _repository.getNotifications(userId: currentUserId);
      final unread = list.where((n) => !n.isRead).length;

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        notifications: list,
        unreadCount: unread,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() => getNotifications();
}

final notificationProvider =
StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(repositoryProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  return NotificationNotifier(repository, prefs);
});