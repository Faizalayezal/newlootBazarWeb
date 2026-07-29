import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/core/theme.dart';

import '../providerd/video/video_list_response.dart';
import '../route/app_routes.dart';


class StoryCard extends StatelessWidget {
  final VideoItem video;
  final VideoProduct productModel;
  final List<VideoItem> allVideos;
  final int initialIndex;

  const StoryCard({
    super.key,
    required this.video,
    required this.allVideos,
    required this.initialIndex,
    required this.productModel,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic user = video.user;
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
          },
        );
      },
      child: Container(
        width: 90.w,
        margin: EdgeInsets.only(bottom: 25.h, right: 12.w),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Main rectangular card
            Container(
              height: 150.h,
              width: 90.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: AppTheme.primary,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: productThumb != null
                    ? CachedNetworkImage(
                        imageUrl: productThumb,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: AppTheme.primary),
                        errorWidget: (_, _, _) => Container(color: AppTheme.primary),
                      )
                    : Container(color: AppTheme.primary),
              ),
            ),
            // Circular profile image overlapping the bottom
            Positioned(
              bottom: -20.h,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppTheme.primary, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: profileImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: profileImage,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => _placeholderIcon(),
                          errorWidget: (_, _, _) => _placeholderIcon(),
                        )
                      : _placeholderIcon(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: Colors.white,
      child: Icon(
        Icons.person_outline,
        color: const Color(0xFFB39EB5),
        size: 24.sp,
      ),
    );
  }
}
