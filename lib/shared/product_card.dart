import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:shimmer/shimmer.dart';

/*class ProductCard extends StatelessWidget {
  ProductCard({
    super.key,
    required this.onTap,
    this.imageUrl,
    this.title,
    this.rate,
    this.pcs,
    this.moq,
    this.location,

  });

  final void Function() onTap;
  final String? imageUrl;
  final String? title;
  final String? rate;
  final String? pcs;
  final String? moq;
  final String? location;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Card(
        color: AppTheme.product,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(2.r),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    topRight: Radius.circular(10.r),
                  ),
                  child: Image.asset(
                    "assets/images/man.png",
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ),
            5.verticalSpace,
            Padding(
              padding: EdgeInsets.all(2.r),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 35.h,
                        child: Text(
                         title??'',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: AppTextStyle.light(
                            size: 11.sp,
                            color: Colors.black,
                            height: 1.3,
                          ),
                        ),
                      ),
                      8.verticalSpace,
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: buildInfoColumn("₹${rate}", "Rate"),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: buildInfoColumn("$pcs", "Pcs"),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: buildInfoColumn("$moq", "MOQ"),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: buildInfoColumn("$location", "Location"),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildInfoColumn(String value, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyle.bold(size: 10.sp, color: Colors.black),
      ),
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyle.light(size: 9.sp, color: Colors.black),
      ),
    ],
  );
}*/

class ProductCard extends StatelessWidget {
  final void Function() onTap;
  final String? imageUrl;
  final String? title;
  final String? rate;
  final String? pcs;
  final String? moq;
  final String? location;

  const ProductCard({
    super.key,
    required this.onTap,
    this.imageUrl,
    this.title,
    this.rate,
    this.pcs,
    this.moq,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Rounded card decoration with outer peach-yellow background matching the screenshot
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0C4), // Perfect high-fidelity yellow-peach color matches screenshot
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            // ─── 1. Top Image Section with Crop Rounding ───
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                ),
                child: imageUrl != null && imageUrl!.startsWith('http')
                    ? CachedNetworkImage(
                  imageUrl: imageUrl??'',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFFFE6DC),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5722)),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildPlaceholderImage(),
                )
                    : _buildPlaceholderImage(),
              ),
            ),

            // ─── 2. Bottom Beautiful White Panel nested with Border Contour ───
            Padding(
              padding: EdgeInsets.only(top:10.h,bottom: 2.h,right: 2.w,left: 2.w), // Creates the perfect nested border contour shown in the screenshot
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r), // Standard nested corner multiplier
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic double-line Title
                    SizedBox(
                      height: 38.h, // Constrained height prevents layout shifts or vertical breaks
                      child: Text(
                        title ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Unified dynamic sizing stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn('₹${rate ?? "0"}', 'Rate'),
                        _buildStatColumn(pcs ?? "0", 'Quantity'), // Matched to 'Quantity' as shown in screenshot
                        _buildStatColumn(moq ?? "0", 'MOQ'),
                        _buildStatColumn(location ?? "-", 'Location'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Safe stat column builder which scales down when inputs are extremely large
  Widget _buildStatColumn(String val, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            val,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8.5.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // Helper placeholder fallback in case image URL is empty or fails
  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFFFF0C4),
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        "assets/images/man.png",
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If local assets/images/man.png is not found, render a clean B2B icon
          return const Center(
            child: Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFFFF5722),
              size: 32,
            ),
          );
        },
      ),
    );
  }
}