import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/di/sharedPrefsProvider.dart';
import 'package:lootbazarweb/providerd/otp/OtpNotifier.dart';
import 'package:lootbazarweb/providerd/otp/OtpState.dart';
import 'package:lootbazarweb/providerd/register/RegisterNotifier.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:lootbazarweb/shared/PremiumLoadingButton.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String countryCode;

  OtpScreen({super.key, required this.phone, required this.countryCode});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static PinTheme get defaultPinTheme => _defaultPinTheme;

  static PinTheme get focusedPinTheme => _focusedPinTheme;

  static PinTheme get submittedPinTheme => _submittedPinTheme;
  var otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final ValueNotifier<int> seconds = ValueNotifier<int>(60);

  /// RESEND SHOW/HIDE
  final ValueNotifier<bool> showResend = ValueNotifier<bool>(false);


  void startTimer() async {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value == 0) {
        timer.cancel();

        showResend.value = true;
      } else {
        seconds.value--;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  /// DEFAULT PIN THEME
  static final PinTheme _defaultPinTheme = PinTheme(
    width: 70.w,
    height: 70.h,

    textStyle: AppTextStyle.semiBold(size: 30.sp, color: Colors.black),

    decoration: BoxDecoration(
      color: Colors.white,

      borderRadius: BorderRadius.circular(10.r),

      border: Border.all(color: Colors.grey.shade300, width: 1.2),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
  );

  /// FOCUSED PIN THEME
  static final PinTheme _focusedPinTheme = defaultPinTheme.copyDecorationWith(
    borderRadius: BorderRadius.circular(10.r),

    border: Border.all(color: AppTheme.primary, width: 1.5),

    color: Colors.orange.withValues(alpha: 0.08),
  );

  /// SUBMITTED / FILLED THEME
  static final PinTheme _submittedPinTheme = defaultPinTheme.copyWith(
    textStyle: AppTextStyle.semiBold(size: 30.sp, color: Colors.white),

    decoration: defaultPinTheme.decoration!.copyWith(
      color: AppTheme.primary,

      borderRadius: BorderRadius.circular(10.r),

      border: Border.all(color: AppTheme.primary),

      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withValues(alpha: 0.25),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    ref.listen<OtpState>(otpProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));

        return;
      }
      if (!next.isSuccess) return;

      if (next.isProfileCompleted) {
        context.goNamed(AppRoutes.homeScreen);
      } else {
        context.go(AppRoutes.setupProfileScreen);
      }
    });
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      bottomSheet: Container(
        color: AppTheme.background,
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 120.h),
          child: Consumer(
            builder: (context, ref, child) {
              final otpState = ref.watch(otpProvider);
              return PremiumLoadingButton(
                isLoading: otpState.isLoading,
                onTap: () async {
                  if (!formKey.currentState!.validate()) return;
                  FocusScope.of(context).unfocus();
                  final mobileNo = "${widget.countryCode}${widget.phone}";
                  // .replaceAll('+', '')
                  // .replaceAll(' ', '');

                  await ref
                      .read(otpProvider.notifier)
                      .verifyOtp(
                        mobileNo: mobileNo,
                        otp: otpController.text.trim(),
                      );
                },
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),

            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    60.verticalSpace,
                    Text(
                      'Enter the code\nsent no WhatsApp',
                      style: AppTextStyle.semiBold(
                        size: 34.sp,
                        height: 1.0,
                        color: Colors.black,
                      ),
                    ),
                    14.verticalSpace,
                    Text(
                      'An OTP has been sent on this WhatsApp Number :',
                      style: AppTextStyle.light(
                        size: 12.sp,
                        color: AppTheme.subtext,
                      ),
                    ),
                    5.verticalSpace,
                    Row(
                      children: [
                        Text(
                          "${widget.countryCode} ${widget.phone}",
                          style: AppTextStyle.light(
                            size: 13.sp,
                            color: Colors.black,
                          ),
                        ),
                        10.horizontalSpace,
                        GestureDetector(
                          onTap: () {
                            //context.canPop();
                            context.pop();
                          },
                          child: Icon(
                            Icons.edit_rounded,
                            color: AppTheme.primary,
                            size: 18.r,
                          ),
                        ),
                      ],
                    ),
                    30.verticalSpace,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: _buildOtpField(),
                    ),
                    30.verticalSpace,
                    ValueListenableBuilder<bool>(
                      valueListenable: showResend,

                      builder: (context, resend, child) {
                        /// SHOW RESEND
                        if (resend) {
                          return GestureDetector(
                            onTap: () async {
                              /// RESET TIMER
                              FocusScope.of(context).unfocus();
                              await ref.read(otpProvider.notifier).requestOtp();
                              seconds.value = 60;

                              showResend.value = false;

                              startTimer();
                            },

                            child: Text(
                              'Resend OTP',
                              textAlign: TextAlign.center,
                              style: AppTextStyle.semiBold(
                                size: 13.sp,
                                color: AppTheme.primary,
                              ),
                            ),
                          );
                        }

                        /// SHOW TIMER
                        return ValueListenableBuilder<int>(
                          valueListenable: seconds,

                          builder: (context, value, child) {
                            final minute = (value ~/ 60).toString().padLeft(
                              2,
                              '0',
                            );

                            final second = (value % 60).toString().padLeft(
                              2,
                              '0',
                            );

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Text(
                                  "Get a new code in ",
                                  style: AppTextStyle.light(
                                    size: 11.sp,
                                    color: AppTheme.subtext,
                                  ),
                                ),

                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),

                                  child: Text(
                                    "$minute : $second",

                                    key: ValueKey(value),

                                    style: AppTextStyle.regular(
                                      size: 12.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField() {
    return Form(
      child: Pinput(
        length: 4,
        // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        controller: otpController,
        keyboardType: TextInputType.number,
        errorTextStyle: AppTextStyle.semiBold(size: 22.sp, color: Colors.red),
        validator: (value) {
          if (value!.isEmpty) {
            return "Please enter your OTP";
          }
          return null;
        },
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        defaultPinTheme: defaultPinTheme,

        focusedPinTheme: focusedPinTheme,

        submittedPinTheme: submittedPinTheme,

        separatorBuilder: (index) => 10.horizontalSpace,
        showCursor: true,

        cursor: Container(
          width: 2.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),

        animationCurve: Curves.easeInOut,

        animationDuration: const Duration(milliseconds: 250),
        onCompleted: (value) {
          if (Platform.isIOS) {
            ScaffoldMessenger.of(context).clearSnackBars();
          }
        },
        onTap: () {
          if (Platform.isIOS) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(minutes: 30),
                backgroundColor: Colors.white,
                content: Text(
                  "",
                  style: AppTextStyle.semiBold(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    size: 15.sp,
                  ),
                ),
                padding: EdgeInsets.zero,
                action: SnackBarAction(
                  label: "Done",
                  textColor: Color.fromRGBO(255, 255, 255, 1),
                  onPressed: () {
                    debugPrint("CLICKED");
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            );
          }
        },
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'\d')),
        ],
      ),
    );
  }
}
