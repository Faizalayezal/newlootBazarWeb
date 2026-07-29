import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/response/NavItem.dart';

import '../shared/app_text_style.dart';
import '../tool/curved_line_painter.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Bottom Navigation
          Positioned(
            bottom: 10.h,
            left: 10.w,
            right: 10.w,
            child: Container(
              height: 55.h,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .12),
                    blurRadius: 20.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildNavItem(
                      context,
                      NavItem.items[0]!,
                      selectedIndex == 0,
                      0,
                    ),
                  ),

                  Expanded(
                    child: _buildNavItem(
                      context,
                      NavItem.items[1]!,
                      selectedIndex == 1,
                      1,
                    ),
                  ),

                  // Center Gap
                  70.horizontalSpace,
                  Expanded(
                    child: _buildNavItem(
                      context,
                      NavItem.items[3]!,
                      selectedIndex == 3,
                      3,
                    ),
                  ),

                  Expanded(
                    child: _buildNavItem(
                      context,
                      NavItem.items[4]!,
                      selectedIndex == 4,
                      4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Sell Button
          Positioned(bottom: 2.h, child: _buildSellFAB(context)),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavItem item,
    bool isSelected,
    int index,
  ) {
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 4.h,
            width: isSelected ? 28 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          2.verticalSpace,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: 1.1,
                      child: SvgPicture.asset(
                        item.icon,
                        width: 23.w,
                        height: 23.h,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),

                   /* if (item.badge)
                      Positioned(
                        top: -2,
                        right: -4,
                        child: Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),*/
                  ],
                ),

                3.verticalSpace,

                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: AppTextStyle.light(
                    size: 10.sp,
                    color: Colors.white,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellFAB(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 77.r,
        height: 77.r,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          //color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 5.h,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: selectedIndex == 2 ? 1 : 0,
                child: CustomPaint(
                  size: Size(57.w, 8.h),
                  painter: CurvedLinePainter(),
                ),
              ),
            ),

            Center(
              child: Container(
                width: 65.w,
                height: 65.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/add.svg',
                        width: 35.w,
                        height: 35.h,
                        colorFilter: const ColorFilter.mode(
                          AppTheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      Text(
                        "Sell",
                        style: AppTextStyle.light(
                          size: 10.sp,
                          color: Colors.black,
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
