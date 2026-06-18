// lib/providers/video/video_state.dart

import 'package:lootbazarweb/providerd/video/VideoListResponse.dart';

class VideoState {
  final bool isLoading;
  final List<VideoItem> videos;
  final String? errorMessage;

  const VideoState({
    this.isLoading = false,
    this.videos = const [],
    this.errorMessage,
  });

  VideoState copyWith({
    bool? isLoading,
    List<VideoItem>? videos,
    String? errorMessage,
  }) {
    return VideoState(
      isLoading: isLoading ?? this.isLoading,
      videos: videos ?? this.videos,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}