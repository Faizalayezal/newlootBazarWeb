import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providerd/video/video_list_response.dart';
import '../route/app_routes.dart';

class StatusCardWidget extends StatelessWidget {
  final VideoItem video;
  final List<VideoItem> allVideos;
  final int initialIndex;

  const StatusCardWidget({
    super.key,
    required this.video,
    required this.allVideos,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final profileImage = video.user?.profileImage ?? '';
    final productThumb = video.product?.imageUrls.isNotEmpty == true
        ? video.product!.imageUrls.first
        : null;
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.storyScreen,
          extra: {
            'videos': allVideos,
            'initialIndex': initialIndex,
          },
        );
      },
      child: SizedBox(
        width: 100.w,
        height: 190.h,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            /// Card
            Positioned.fill(
              bottom: 20.h,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFC6B6C0),
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
            ),

            /// White Cut Area
            Positioned(
              bottom: 0,
              child: Container(
                width: 50.w,
                height: 30.h,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
              ),
            ),

            /// Avatar
            Positioned(
              bottom: 0,
              child: Container(
                width: 45.w,
                height: 45.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFB9AAB4), width: 2),
                ),
                child: productThumb != null
                    ? CachedNetworkImage(
                  imageUrl: productThumb,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: const Color(0xFFFFE6DC),
                  ),
                  errorWidget: (_, _, _) =>
                      _profileFallback(profileImage),
                )
                    : _profileFallback(profileImage),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _profileFallback(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, _) =>
            Container(color: const Color(0xFFFFE6DC)),
        errorWidget: (_, _, _) => Container(
          color: const Color(0xFFFFE6DC),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      );
    }
    return Container(
      color: const Color(0xFFFFE6DC),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }

}
