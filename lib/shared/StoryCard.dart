import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/providerd/Products/ProductModel.dart';
import 'package:lootbazarweb/providerd/Products/ProductState.dart';
import 'package:lootbazarweb/providerd/video/VideoListResponse.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';

class StoryCard extends StatelessWidget {
  final VideoItem video;
  final VideoProduct productModel;
  final List<VideoItem> allVideos;
  final int initialIndex;

  const StoryCard({
    required this.video,
    required this.allVideos,
    required this.initialIndex,
    required this.productModel,
  });

  @override
  Widget build(BuildContext context) {
    final userName = video.user?.name ?? '';
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
            'productModel': productModel,
          },
        );
      },
      child: SizedBox(
        width: 72.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Circular avatar with orange ring + video thumbnail overlay ──
            Stack(
              alignment: Alignment.center,
              children: [
                // Orange ring
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF5722),
                      width: 2.5,
                    ),
                  ),
                ),
                // Avatar / product thumbnail
                ClipOval(
                  child: SizedBox(
                    width: 65.w,
                    height: 65.w,
                    child: productThumb != null
                        ? CachedNetworkImage(
                      imageUrl: productThumb,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFFFFE6DC),
                      ),
                      errorWidget: (_, __, ___) =>
                          _profileFallback(profileImage),
                    )
                        : _profileFallback(profileImage),
                  ),
                ),
                // Play icon overlay
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            // User name
            Text(
              userName.isEmpty ? 'Video' : userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
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
        placeholder: (_, __) =>
            Container(color: const Color(0xFFFFE6DC)),
        errorWidget: (_, __, ___) => Container(
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