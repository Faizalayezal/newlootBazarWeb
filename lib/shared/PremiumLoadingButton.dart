import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';

class PremiumLoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  final String label;
  final String iconAsset;
  const PremiumLoadingButton({
    super.key,
    required this.isLoading,
    required this.onTap,
    this.label = 'Continue',
    this.iconAsset = 'assets/images/arrowfor.svg',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fullWidth = constraints.maxWidth;
          final double collapsedSize = 54.h;
          return GestureDetector(
            onTap: isLoading ? null : onTap,
            child: Align(
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                width: isLoading ? collapsedSize : fullWidth,
                height: 54.h,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(50.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(
                        alpha: isLoading ? 0.35 : 0.18,
                      ),
                      blurRadius: isLoading ? 14 : 10,
                      spreadRadius: isLoading ? 0.5 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                // Clip so any partially-collapsed content never paints outside
                clipBehavior: Clip.antiAlias,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: isLoading
                      ? Center(
                    key: const ValueKey('spinner'),
                    child: SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  )
                      : Padding(
                    key: const ValueKey('content'),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Flexible + ellipsis so it shrinks instead of overflowing
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.semiBold(
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          iconAsset,
                          width: 28.w,
                          height: 28.h,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}