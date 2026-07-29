import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/constant/app_toast.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/register/register_notifier.dart';
import 'package:lootbazarweb/providerd/register/register_state.dart';
import 'package:lootbazarweb/route/app_routes.dart';
import 'package:lootbazarweb/shared/app_text_style.dart';
import 'package:lootbazarweb/shared/premium_loading_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  final phoneController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  late ValueNotifier<Country> selectedCountry;

  @override
  void initState() {
    super.initState();

    selectedCountry = ValueNotifier(
      Country.parse('IN'),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    selectedCountry.dispose();
    super.dispose();
  }
  void _onContinueTap() {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    final fullNumber =
        '${selectedCountry.value.phoneCode}${phoneController.text.trim()}';

    ref.read(registerProvider.notifier).register(mobileNo: fullNumber);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final registerState = ref.watch(registerProvider);

    // Navigation aur error — screen level pe
    ref.listen<RegisterState>(registerProvider, (previous, next) {
      if (next.isSuccess && next.data != null) {
        AppToast.success(next.data?.otp??"");
        ref.read(registerProvider.notifier).reset();

        context.pushNamed(
          AppRoutes.otpScreen,
          extra: {
            'phone': phoneController.text.trim(),
            'countryCode': selectedCountry.value.phoneCode,
            'otp': next.data?.otp??"",
            'userId': next.data!.user.id,
          },
        );
      }

      if (next.errorMessage != null) {
        AppToast.error(next.errorMessage??'');
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      bottomSheet: Container(
        color: AppTheme.background,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            bottom: 80.h,
          ),
          child: PremiumLoadingButton(
            isLoading: registerState.isLoading,
            onTap: () {
              _onContinueTap();
            },
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              right: 22.w,
              left: 22.w,
              bottom: MediaQuery.viewInsetsOf(context).bottom,
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
                      'Enter your\nWhatsApp number',
                      style: AppTextStyle.semiBold(
                        size: 34.sp,
                        height: 1.0,
                        color: Colors.black,
                      ),
                    ),
                    14.verticalSpace,
                    Text(
                      'An OTP sign in or create a new account will be sent to this number',
                      style: AppTextStyle.light(
                        size: 12.sp,
                        color: AppTheme.subtext,
                      ),
                    ),
                    30.verticalSpace,
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showCountryPicker(
                              context: context,

                              showPhoneCode: true,

                              countryListTheme: CountryListThemeData(
                                borderRadius: BorderRadius.circular(24.r),

                                bottomSheetHeight: screenHeight * 0.82,

                                inputDecoration: InputDecoration(
                                  hintText: 'Search country',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                              ),

                              onSelect: (Country country) {
                                selectedCountry.value = country;
                              },
                            );
                          },

                          child: ValueListenableBuilder<Country>(
                            valueListenable: selectedCountry,

                            builder: (context, country, child) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),

                                curve: Curves.easeOut,

                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 12.h,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.08),

                                  borderRadius: BorderRadius.circular(18.r),

                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                  ),
                                ),

                                child: Row(
                                  children: [
                                    Text(
                                      country.flagEmoji,
                                      style: TextStyle(fontSize: 20.sp),
                                    ),

                                    8.horizontalSpace,

                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),

                                      transitionBuilder: (child, animation) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.4),
                                            end: Offset.zero,
                                          ).animate(animation),

                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },

                                      child: Text(
                                        '+${country.phoneCode}',

                                        key: ValueKey(country.phoneCode),

                                        style: AppTextStyle.semiBold(
                                          size: 22.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),

                                    4.horizontalSpace,

                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 22.sp,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        12.horizontalSpace,

                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onContinueTap(),
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: (value) {
                              /// EMPTY VALIDATION
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number required';
                              }

                              /// MIN LENGTH VALIDATION
                              if (value.length < 5) {
                                return 'Minimum 5 digits required';
                              }

                              /// MAX LENGTH VALIDATION
                              if (value.length > 11) {
                                return 'Maximum 11 digits allowed';
                              }

                              return null;
                            },
                            style: AppTextStyle.semiBold(
                              size: 22.sp,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: '0000 000-00-00',
                              border: InputBorder.none,
                              hintStyle: AppTextStyle.light(
                                size: 18.sp,
                                color: Colors.grey,
                              ),

                              errorStyle: AppTextStyle.semiBold(size: 11.sp),
                            ),
                          ),
                        ),
                      ],
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
}
