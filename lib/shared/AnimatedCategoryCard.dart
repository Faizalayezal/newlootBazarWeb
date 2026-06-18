import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:lootbazarweb/shared/CustomHalfCircleClipper.dart';

class AnimatedCategoryCard extends StatefulWidget {
  final String title;
  final Color color;
  final int delay;
  final bool isSelected;

  const AnimatedCategoryCard({
    super.key,
    required this.title,
    required this.color,
    required this.delay,
    this.isSelected = false,
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
    final borderRadius = BorderRadius.circular(12.r);

    return AnimatedScale(
      duration: const Duration(milliseconds: 500),
      scale: isVisible ? 1 : 0.7,
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: isVisible ? 1 : 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primary
                  : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: double.infinity,
              color: widget.color,
              child: Stack(
                children: [
                  /// Background Circle
                  Positioned(
                    top: 5.h,
                    left: 60.w,
                    child: ClipPath(
                      clipper: CustomHalfCircleClipper(),
                      child: Container(
                        height: MediaQuery.of(context).size.width,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width / 3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Title
                  Padding(
                    padding: EdgeInsets.only(
                      left: 14.w,
                      right: 16.w,
                      top: 14.h,
                      bottom: 14.h,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.italic(
                          size: 15.sp,
                          color: AppTheme.category,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),

                  /// Selected Icon
                  if (widget.isSelected)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: AppTheme.primary,
                          size: 20.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
