import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';

class StoryWhatsappButtons extends StatelessWidget {
  const StoryWhatsappButtons({
    super.key,
    required this.onTap,
    required this.title,
    required this.price,
    required this.stock,
    required this.moq,
    required this.location,
  });

  final void Function() onTap;
  final String title;
  final String price;
  final String stock;
  final String moq;
  final String location;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 78.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.25),
              offset: const Offset(2, 3),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left: WhatsApp icon block ──
            Container(
              width: 68.w,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  bottomLeft: Radius.circular(8.r),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/whatsapp.svg',
                  height: 35.h,
                  width: 35.w,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            // ── Right: Product info card ──
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: const BoxDecoration(
                  color: Colors.white, // deeper WhatsApp-green tone
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bold(
                        size: 14.sp,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat('₹$price', 'Rate'),
                        _buildStat(stock, 'Pcs'),
                        _buildStat(moq, 'MOQ'),
                        _buildStat(location, 'Location'),
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

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: AppTextStyle.bold(size: 12.sp, color: Colors.black),
        ),
        if (label.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTextStyle.bold(size: 10.sp, color: Colors.black38),
          ),
        ],
      ],
    );
  }
}