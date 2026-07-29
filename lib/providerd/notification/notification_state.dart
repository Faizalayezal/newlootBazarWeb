// lib/providerd/notification/notification_state.dart

import 'package:flutter/foundation.dart';
import 'package:lootbazarweb/providerd/notification/notification_product.dart';

@immutable
class NotificationState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  static const Object _sentinel = Object();

  NotificationState copyWith({
    bool? isLoading,
    bool? isSuccess,
    Object? errorMessage = _sentinel,
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}