import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/CityState.dart';
import 'package:lootbazarweb/providerd/register/RegisterNotifier.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:lootbazarweb/shared/CityPickerSheet.dart';
import 'package:lootbazarweb/shared/PremiumLoadingButton.dart';


class ProfileRegisterScreen extends ConsumerStatefulWidget {
  const ProfileRegisterScreen({super.key});
  @override
  ConsumerState<ProfileRegisterScreen> createState() => _ProfileRegisterScreenState();
}

class _ProfileRegisterScreenState extends ConsumerState<ProfileRegisterScreen> {
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ✅ Dedicated focus nodes so we can control focus explicitly
  final nameFocusNode = FocusNode();
  final pincodeFocusNode = FocusNode();

  File? _pickedImage;
  bool _showImageError = false;

  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    nameFocusNode.dispose();
    pincodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _openCityPicker() async {
    // ✅ Close any open keyboard BEFORE opening the sheet
    FocusManager.instance.primaryFocus?.unfocus();

    final cityState = ref.read(cityProvider);
    if (cityState.cities.isEmpty && !cityState.isLoading) {
      ref.read(cityProvider.notifier).loadCities();
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CityPickerSheet(),
    );

    // ✅ Ensure nothing grabs focus after the sheet closes
    FocusManager.instance.primaryFocus?.unfocus();

    if (!mounted) return;

    if (selected != null && selected.isNotEmpty) {
      setState(() => cityController.text = selected);
    }
  }

  void _onSubmitTap() {
    setState(() {
      _showImageError = _pickedImage == null;
    });

    if (_showImageError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(registerProvider.notifier).localStore(
      userName: nameController.text.trim(),
      userAddress: cityController.text.trim(),
      userPinCode: pincodeController.text.trim(),
      userImage: _pickedImage?.path ?? '',
    );
    context.goNamed(AppRoutes.interestScreen);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.background,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: true, // ✅ allow proper resize for pincode field
          backgroundColor: AppTheme.background,
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    60.verticalSpace,
                    Text(
                      'Setup your\nprofile',
                      style: AppTextStyle.semiBold(
                          size: 34.sp, height: 1.0, color: Colors.black),
                    ),
                    14.verticalSpace,
                    Text(
                      'Add your details so others can recognize you',
                      style: AppTextStyle.light(
                          size: 12.sp, color: AppTheme.subtext),
                    ),
                    30.verticalSpace,
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          await _pickImage();
                          if (_pickedImage != null) {
                            setState(() => _showImageError = false);
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: _showImageError
                                    ? Border.all(color: Colors.red, width: 2)
                                    : null,
                              ),
                              child: CircleAvatar(
                                radius: 55.r,
                                backgroundColor: _showImageError
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                backgroundImage: _pickedImage != null
                                    ? FileImage(_pickedImage!)
                                    : null,
                                child: _pickedImage == null
                                    ? Icon(Icons.person,
                                        size: 50.sp,
                                        color: _showImageError
                                            ? Colors.red
                                            : Colors.orange)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  border:
                                  Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(Icons.camera_alt,
                                    size: 16.sp, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    30.verticalSpace,
                    Text('Full Name',
                        style:
                        AppTextStyle.semiBold(size: 14.sp, color: Colors.black)),
                    8.verticalSpace,
                    TextFormField(
                      controller: nameController,
                      focusNode: nameFocusNode,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        // ✅ explicitly move to next field instead of
                        // letting Flutter auto-pick the next focusable widget
                        FocusScope.of(context).unfocus();
                        _openCityPicker();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                      style: AppTextStyle.semiBold(size: 16.sp, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle:
                        AppTextStyle.light(size: 14.sp, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.orange.withOpacity(0.06),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    20.verticalSpace,

                    // ---------- CITY FIELD ----------
                    Text('City',
                        style:
                        AppTextStyle.semiBold(size: 14.sp, color: Colors.black)),
                    8.verticalSpace,
                    GestureDetector(
                      onTap: _openCityPicker,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: cityController,
                          focusNode: FocusNode(
                            canRequestFocus: false, // ✅ never receives focus
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'City is required';
                            }
                            return null;
                          },
                          style:
                          AppTextStyle.semiBold(size: 16.sp, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Select your city',
                            hintStyle: AppTextStyle.light(
                                size: 14.sp, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.orange.withOpacity(0.06),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 14.h),
                            suffixIcon: Icon(Icons.location_city,
                                color: AppTheme.primary, size: 20.sp),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    20.verticalSpace,

                    Text('Pincode',
                        style:
                        AppTextStyle.semiBold(size: 14.sp, color: Colors.black)),
                    8.verticalSpace,
                    TextFormField(
                      controller: pincodeController,
                      focusNode: pincodeFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Pincode is required';
                        }
                        if (value.trim().length != 6) {
                          return 'Pincode must be 6 digits';
                        }
                        return null;
                      },
                      style: AppTextStyle.semiBold(size: 16.sp, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Enter pincode',
                        hintStyle:
                        AppTextStyle.light(size: 14.sp, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.orange.withOpacity(0.06),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    40.verticalSpace,
                    PremiumLoadingButton(isLoading: false, onTap: _onSubmitTap),
                    70.verticalSpace,
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