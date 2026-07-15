import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';

class SwipeButton extends StatefulWidget {
  final Future<void> Function()? onCall;
  final bool? isChecked;
  final int? status;
  final bool isApiLoading;
  final double? amount;

  const SwipeButton({
    super.key,
    this.onCall,
    this.isChecked,
    this.status,
    required this.isApiLoading,
    this.amount,
  });

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton>
    with TickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _spinController;
  late AnimationController _snapController;
  late Animation<double> _snapAnim;

  double _dragX = 0;
  double _trackWidth = 0;

  // thumb size + padding — must match build()
  static const double _thumbSize = 44;
  static const double _pad = 6;

  double get _maxDrag => _trackWidth - _thumbSize - _pad * 2;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant SwipeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isApiLoading && !widget.isApiLoading) {
      if (mounted) {
        _spinController.stop();
        _spinController.reset();
        _snapBack();
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _snapController.dispose();
    super.dispose();
  }

  void _snapBack() {
    _snapAnim = Tween<double>(begin: _dragX, end: 0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOut),
    )..addListener(() {
      setState(() => _dragX = _snapAnim.value);
    });
    _snapController.forward(from: 0);
  }

  Future<void> _triggerPayment() async {
    if (_isProcessing || widget.isApiLoading) return;
    setState(() => _isProcessing = true);
    _spinController.repeat();
    await widget.onCall?.call();
    if (mounted && !widget.isApiLoading) {
      _spinController.stop();
      _spinController.reset();
      _snapBack();
      setState(() => _isProcessing = false);
    }
  }

  bool get _isFree => (widget.status == 200 && widget.isChecked == true) || (widget.amount != null && widget.amount == 0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // ✅ Local variable — koi setState nahi, koi postFrameCallback nahi
          final double trackW = constraints.maxWidth.clamp(0.0, 320.w);
          final double thumbSize = 44.w;
          final double pad = 6.w;
          final double maxDrag = trackW - thumbSize - pad * 2;

          String btnText = 'Slide to Pay | ₹${widget.amount ?? 33}';
          if (_isProcessing) {
            btnText = 'Processing...';
          } else if (_isFree) {
            btnText = 'Free';
          }

          return GestureDetector(
            onHorizontalDragUpdate: _isProcessing
                ? null
                : (d) {
              setState(() {
                _dragX = (_dragX + d.delta.dx).clamp(0.0, maxDrag);
              });
            },
            onHorizontalDragEnd: _isProcessing
                ? null
                : (d) async {
              if (_dragX >= maxDrag * 0.9) {
                await _triggerPayment();
              } else {
                _snapBack();
              }
            },
            child: SizedBox(
              width: trackW,
              height: 56.h,
              child: Stack(
                children: [
                  // Track background
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3BD75D),
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                    ),
                  ),

                  // Progress fill
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: (pad + _dragX + thumbSize).clamp(0.0, trackW),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                    ),
                  ),

                  // Center label
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        btnText,
                        style: AppTextStyle.regular(
                          size: 15.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Draggable thumb
                  Positioned(
                    left: pad + _dragX,
                    top: 6.h,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _isProcessing
                            ? RotationTransition(
                          turns: _spinController,
                          child: SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              backgroundColor: Colors.grey.shade200,
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                Color(0xFF3BD75D),
                              ),
                            ),
                          ),
                        )
                            : SvgPicture.asset(
                          'assets/images/arrow.svg',
                          width: 20.w,
                          height: 20.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}