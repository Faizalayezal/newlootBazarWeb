// lib/providers/video/video_notifier.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/network_manager/repository.dart';
import 'package:lootbazarweb/providerd/di/repositoryProvider.dart';
import 'package:lootbazarweb/providerd/video/VideoState.dart';

class VideoNotifier extends StateNotifier<VideoState> {
  final Repository _repository;

  VideoNotifier(this._repository) : super(const VideoState());

  Future<void> getVideos() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _repository.getVideos();
      state = state.copyWith(
        isLoading: false,
        videos: response.videos,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final videoProvider =
StateNotifierProvider.autoDispose<VideoNotifier, VideoState>((ref) {
  final repository = ref.watch(repositoryProvider);
  return VideoNotifier(repository);
});