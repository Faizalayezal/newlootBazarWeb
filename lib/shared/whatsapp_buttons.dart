
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';

class WhatsappButtons extends StatelessWidget {
  const WhatsappButtons({
    super.key,
    required this.onTap,
    this.productDesc,
    this.location,
  });

  final VoidCallback onTap;
  final String? productDesc;
  final String? location;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 340.w,
        height: 75.h,
        child: Stack(
          children: [
            /// White Card
            Positioned(
              left: 40.w,
              child: Container(
                width: 300.w,
                height: 75.h,
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(6.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                  left: 45.w,
                  right: 10.w,
                  top: 6.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productDesc ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.regular(
                        size: 18.sp,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      location?.replaceFirst(" ", ", ") ?? "",
                      style: AppTextStyle.regular(
                        size: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        /*Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 13.sp,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 13.sp,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 13.sp,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 13.sp,
                        ),
                        Icon(
                          Icons.star_half,
                          color: Colors.amber,
                          size: 13.sp,
                        ),

                        SizedBox(width: 12.w),*/

                        Text(
                          "TRUSTED",
                          style: AppTextStyle.bold(
                            size: 13.sp,
                            color: const Color(0xff6B2358),
                          ),
                        ),

                        SizedBox(width: 4.w),

                        Icon(
                          Icons.thumb_up_alt,
                          color: const Color(0xff6B2358),
                          size: 14.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// WhatsApp Green Box
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 66.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: const Color(0xff25D366),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/images/whatsapp.svg",
                      width: 28.w,
                      height: 28.w,
                      colorFilter: const ColorFilter.mode(
                        Colors.red,
                        BlendMode.srcIn,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      "Chat Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
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
}