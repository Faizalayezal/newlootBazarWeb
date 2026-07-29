import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'app_text_style.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'category_curve_clipper.dart';

class AnimatedCategoryCard extends StatefulWidget {
  final String title;
  final String? image;
  final Color color;
  final int delay;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedCategoryCard({
    super.key,
    required this.title,
    this.image,
    required this.color,
    required this.delay,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<AnimatedCategoryCard> createState() => _AnimatedCategoryCardState();
}

class _AnimatedCategoryCardState extends State<AnimatedCategoryCard>
    with SingleTickerProviderStateMixin {
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        setState(() {
          isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 500),
        scale: isVisible ? 1 : 0.85,
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: isVisible ? 1 : 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: widget.isSelected ? AppTheme.primary : Colors.transparent, // Your AppTheme.primary
                width: 2.w,
              ),
              boxShadow: [
                if (widget.isSelected)
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                color: widget.color,
                height: 100.h, // Relative height
                child: Stack(
                  children: [
                    /// 1. PERFECT CURVED FRAME FOR BACKGROUND AND IMAGE
                    /// By wrapping the entire white background and the image inside
                    /// a single ClipPath, any image automatically clips exactly
                    /// to the curve of the frame! No overflow, no awkward gaps!
                    Positioned.fill(
                      child: ClipPath(
                        clipper: CategoryCurveClipper(
                          startXRatio: 0.45, // Synchronized from designer
                          endYRatio: 0.15,
                        ),
                        child: Container(
                          color: Colors.white,
                          child: widget.image != null && widget.image!.trim().isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: widget.image!.trim().replaceAll(RegExp(r'\s+'), ''),
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 20.sp,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          )
                              : const SizedBox(),
                        ),
                      ),
                    ),

                    /// 2. Title Text (On the colored side, guaranteed safe spacing)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 5.w,
                        top: 12.h,
                        bottom: 12.h,
                        right: (1.0 - 0.45) * 100.w + 15.w, // Dynamic padding based on curve start
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.title.replaceAll(' & ', ' &\n'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.italic(
                            size: 12.sp,
                            color: const Color(0xFF4A2C2C), // Dark brownish text matching image
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),

                    /// 3. Selection indicator (Top-Right Badge)
                    if (widget.isSelected)
                      Positioned(
                        top: 5.h,
                        right: 9.w,
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ]
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: AppTheme.primary, // Your AppTheme.primary
                            size: 17.sp,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
