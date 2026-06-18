import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';

class PremiumLoadingButton extends StatefulWidget {
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
  State<PremiumLoadingButton> createState() => _PremiumLoadingButtonState();
}

class _PremiumLoadingButtonState extends State<PremiumLoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(PremiumLoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      // Loading shuru — fill loop start karo
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      // Loading khatam — reset
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 54.h,
        decoration: BoxDecoration(
          color: widget.isLoading ? Colors.transparent : AppTheme.primary,
          borderRadius: BorderRadius.circular(50.r),
          border: widget.isLoading
              ? Border.all(color: AppTheme.primary, width: 1.5)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: Stack(
            children: [
              // ── Shimmer fill layer (loading me) ──
              if (widget.isLoading)
                AnimatedBuilder(
                  animation: _fillAnimation,
                  builder: (context, _) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _fillAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withValues(alpha: 0.3),
                                AppTheme.primary.withValues(alpha: 0.85),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // ── Content ──
              SizedBox(
                height: 54.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 5.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: widget.isLoading
                            ? Text(
                          'Please wait...',
                          key: const ValueKey('loading'),
                          style: AppTextStyle.semiBold(
                            size: 16.sp,
                            color: AppTheme.primary,
                          ),
                        )
                            : Text(
                          widget.label,
                          key: const ValueKey('label'),
                          style: AppTextStyle.semiBold(
                            size: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Arrow ya spinner
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: child,
                        ),
                        child: widget.isLoading
                            ? SizedBox(
                          key: const ValueKey('spinner'),
                          width: 26.w,
                          height: 26.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.primary,
                          ),
                        )
                            : SvgPicture.asset(
                          widget.iconAsset,
                          key: const ValueKey('arrow'),
                          width: 32.w,
                          height: 32.h,
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
}