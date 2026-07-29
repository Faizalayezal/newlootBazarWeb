import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_text_style.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    this.title = 'No products found',
    this.subtitle = 'We couldn\'t find any products here. Check back later for new arrivals!',
    this.icon = Icons.inventory_2_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64.sp,
              color: Colors.grey.shade300,
            ),
          )
          .animate()
          .scale(duration: 600.ms, curve: Curves.bounceOut)
          .fadeIn(duration: 400.ms),
          
          SizedBox(height: 20.h),
          
          Text(
            title,
            style: AppTextStyle.bold(size: 18.sp, color: Colors.black87),
          )
          .animate()
          .fadeIn(delay: 200.ms, duration: 400.ms)
          .moveY(begin: 10, end: 0),
          
          SizedBox(height: 8.h),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyle.regular(size: 14.sp, color: Colors.grey.shade500),
            ),
          )
          .animate()
          .fadeIn(delay: 400.ms, duration: 400.ms)
          .moveY(begin: 10, end: 0),
        ],
      ),
    );
  }
}
