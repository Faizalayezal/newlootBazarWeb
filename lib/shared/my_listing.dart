import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';

class MyListing extends StatelessWidget {
  const MyListing({
    super.key,
    required this.onTap,
    this.imageUrl,
    this.title,
    this.rate,
    this.pcs,
    this.moq,
    this.location,
    this.status = "Active", // "Active" | "Expand" | "Inactive"
  });

  final VoidCallback onTap;
  final String? imageUrl;
  final String? title;
  final String? rate;
  final String? pcs;
  final String? moq;
  final String? location;
  final String status;

  @override
  Widget build(BuildContext context) {
    // Determine colors based on status matching the UI exactly
    final bool isActive = status.toLowerCase() == 'active';

    final String statusIcon = isActive
        ? 'assets/images/active.svg'
        : 'assets/images/expir.svg';

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.all(Radius.circular(12.r)),
            border: Border.all(
              color: const Color(0xFFFFDCD0).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Image with ClipRRect
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11.r),
                  bottomLeft: Radius.circular(11.r),
                ),
                child: CachedNetworkImage(
                  height: 98.h,
                  width: 90.w,
                  fit: BoxFit.cover,
                  imageUrl: imageUrl ?? '',
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFFCE9DF),
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: const Color(0xFFF34E17).withOpacity(0.5),
                        size: 26.sp,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFFCE9DF),
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: const Color(0xFFF34E17).withOpacity(0.5),
                        size: 26.sp,
                      ),
                    ),
                  ),
                ),
              ),

              // Right Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title (Wrap with simple padding to avoid overlaying the badge)
                          Padding(
                            padding: EdgeInsets.only(right: 54.w),
                            child: Text(
                              title ?? 'Product Title',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF2C2C2C),
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // 4 Column specs: Rate | Quantity | MOQ | Location
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 20.w,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSpecItem("₹ $rate", "Rate"),
                                _buildSpecItem(pcs ?? '0', "Quantity"),
                                _buildSpecItem(moq ?? '0', "MOQ"),
                                _buildSpecItem(location ?? '-', "Location"),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Status Badge (Top Right Corner)
                      Positioned(
                        top: -2.h,
                        right: 0,
                        child: SvgPicture.asset(
                          statusIcon,
                          width: 14.w,
                          height: 14.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem(String title, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyle.bold(color: Colors.black, size: 14.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          subtitle,
          style: AppTextStyle.regular(color: Colors.grey.shade600, size: 10.sp),
        ),
      ],
    );
  }
}
