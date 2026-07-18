import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';

class MyListing extends StatefulWidget {
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
  State<MyListing> createState() => _MyListingState();
}

class _MyListingState extends State<MyListing> {

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600;
  }
  @override
  Widget build(BuildContext context) {
    final bool tablet = _isTablet(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: widget.onTap,
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
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11.r),
                  bottomLeft: Radius.circular(11.r),
                ),
                child: CachedNetworkImage(
                  height: tablet ? 120.h : 98.h,
                  width: tablet ? 80.w : 90.w,
                  fit: BoxFit.cover,
                  imageUrl: widget.imageUrl ?? '',
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
                              widget.title ?? 'Product Title',
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
                                _buildSpecItem("₹ ${widget.rate}", "Rate"),
                                _buildSpecItem(widget.pcs ?? '0', "Quantity"),
                                _buildSpecItem(widget.moq ?? '0', "MOQ"),
                                _buildSpecItem(widget.location ?? '-', "Location"),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Status Badge (Top Right Corner)
                      Positioned(
                        top: -2.h,
                        right: 0,
                        child: _buildStatusBadge(widget.status),
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

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    String label = status;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = Colors.green;
        label = "Active";
        break;
      case 'pending':
        bgColor = const Color(0xFFFFB800);
        label = "Pending";
        break;
      case 'cancel':
      case 'cancelled':
        bgColor = Colors.red;
        label = "Cancelled";
        break;
      case 'expired':
      case 'inactive':
      default:
        bgColor = Colors.grey;
        label = status.isNotEmpty ? status[0].toUpperCase() + status.substring(1).toLowerCase() : "";
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: AppTextStyle.bold(
          size: 10.sp,
          color: Colors.white,
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
