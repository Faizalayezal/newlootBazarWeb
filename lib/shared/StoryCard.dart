import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/providerd/Products/ProductModel.dart';
import 'package:lootbazarweb/providerd/Products/ProductState.dart';
import 'package:lootbazarweb/providerd/video/VideoListResponse.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/screens/StoryScreen.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';

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
    final dynamic user = video.user ?? video.user?.id??'';
    final dynamic product = video.product ?? video.id;
    final String sellerName = user?.name ?? 'Seller';

    final productThumb = video.product?.imageUrls.isNotEmpty == true
        ? video.product!.imageUrls.first
        : null;
    final String profileImage = user?.profileImage ?? '';

    return GestureDetector(
      onTap: () {
        context.pushNamed(
            AppRoutes.storyScreen,
            extra: {
              'videos': allVideos,
              'initialIndex': initialIndex,
              'productModel': productModel,
            },);
      },
      child: SizedBox(
        width: 76.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
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
                ClipOval(
                  child: SizedBox(
                    width: 64.w,
                    height: 64.w,
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
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
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
            SizedBox(height: 6.h),
            Text(
              product?.title ?? sellerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111111),
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
        placeholder: (_, __) => Container(color: const Color(0xFFFFE6DC)),
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