import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/CityState.dart';
import 'package:lootbazarweb/providerd/register/RegisterNotifier.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:lootbazarweb/shared/CityPickerSheet.dart';
import 'package:lootbazarweb/utils/preferences.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();

  XFile? _pickedXFile;
  bool _isEditing = false;
  String? _networkImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _nameController.text = SharedPrefs().getString(name) ?? '';
      _addressController.text = SharedPrefs().getString(address) ?? '';
      _pincodeController.text = SharedPrefs().getString(pincode) ?? '';
      _phoneController.text = SharedPrefs().getString(phoneNumber) ?? '';
      _networkImageUrl = SharedPrefs().getString(profileImage);
      _pickedXFile = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedXFile = picked;
      });
    }
  }

  Future<void> _openCityPicker() async {
    if (!_isEditing) return;
    
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

    FocusManager.instance.primaryFocus?.unfocus();

    if (!mounted) return;

    if (selected != null && selected.isNotEmpty) {
      setState(() => _addressController.text = selected);
    }
  }

  Future<void> _updateProfile() async {
    // 1. Call API with values from controllers
    await ref.read(registerProvider.notifier).updateProfile(
          newName: _nameController.text.trim(),
          newAddress: _addressController.text.trim(),
          newPincode: _pincodeController.text.trim(),
          newImage: _pickedXFile,
        );

    final state = ref.read(registerProvider);
    if (state.errorMessage == null) {
      setState(() => _isEditing = false);
      _loadUserData(); // Reload to sync UI with successfully saved data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${state.errorMessage}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 24.sp),
            SizedBox(width: 10.w),
            Text('Logout', style: AppTextStyle.bold(size: 20.sp)),
          ],
        ),
        content: Text('Are you sure you want to logout?', 
          style: AppTextStyle.regular(size: 14.sp, color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyle.medium(size: 14.sp, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await SharedPrefs().clearUserPrefs();
              if (!mounted) return;
              context.goNamed(AppRoutes.loginScreen);
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('Logout', style: AppTextStyle.medium(size: 14.sp, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _isEditing 
          ? AppBar(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Text('Edit Profile', style: AppTextStyle.bold(size: 18.sp)),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _loadUserData();
                  setState(() {
                    _isEditing = false;
                  });
                },
              ),
            )
          : null,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: _isEditing ? 20.h : MediaQuery.of(context).padding.top + 20.h,
                  bottom: 30.h,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? _pickImage : null,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 55.r,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _getProfileImage(),
                              child: _shouldShowPlaceholder() 
                                ? Icon(Icons.person, size: 55.sp, color: Colors.grey)
                                : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_isEditing) {
                              _pickImage();
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)]),
                            child: Icon(
                              _isEditing ? Icons.camera_alt : Icons.edit,
                              color: AppTheme.primary,
                              size: 18.sp,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 15.h),
                    if (!_isEditing) ...[
                      Text(
                        _nameController.text.isEmpty ? 'LootBazar User' : _nameController.text,
                        style: AppTextStyle.bold(size: 22.sp, color: Colors.white),
                      ),
                      Text(
                        _phoneController.text,
                        style: AppTextStyle.regular(size: 14.sp, color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),

              // Content Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
                child: _isEditing ? _buildEditForm() : _buildProfileMenu(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_pickedXFile != null) {
      if (kIsWeb) return NetworkImage(_pickedXFile!.path);
      return FileImage(File(_pickedXFile!.path));
    }
    if (_networkImageUrl != null && _networkImageUrl!.isNotEmpty) {
      if (_networkImageUrl!.startsWith('http')) {
        return CachedNetworkImageProvider(_networkImageUrl!);
      } else {
        if (kIsWeb) return NetworkImage(_networkImageUrl!);
        return FileImage(File(_networkImageUrl!));
      }
    }
    return null;
  }

  bool _shouldShowPlaceholder() {
    return _pickedXFile == null && (_networkImageUrl == null || _networkImageUrl!.isEmpty);
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _customField(_nameController, 'Full Name', Icons.person_outline),
        SizedBox(height: 16.h),
        _customField(_phoneController, 'Phone Number', Icons.phone_android, enabled: false),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _openCityPicker,
          child: AbsorbPointer(
            child: _customField(_addressController, 'City', Icons.location_on_outlined),
          ),
        ),
        SizedBox(height: 16.h),
        _customField(_pincodeController, 'Pincode', Icons.pin_drop_outlined, keyboardType: TextInputType.number),
        SizedBox(height: 32.h),
        SizedBox(
          width: double.infinity,
          height: 55.h,
          child: ElevatedButton(
            onPressed: ref.watch(registerProvider).isLoading ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
              elevation: 0,
            ),
            child: ref.watch(registerProvider).isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Save Changes', style: AppTextStyle.bold(size: 16.sp, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _customField(TextEditingController controller, String label, IconData icon, {bool enabled = true, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: AppTextStyle.medium(size: 15.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20.sp),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: const BorderSide(color: AppTheme.primary)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide(color: Colors.grey.shade100)),
      ),
    );
  }

  void _showAboutUsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 30.h),
                    // App Logo
                    Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset('assets/applogo.png', width: 60.w, height: 60.w),
                    ),
                    SizedBox(height: 15.h),
                    Text('LootBazar', style: AppTextStyle.bold(size: 24.sp)),
                    Text('Version 1.0.0', style: AppTextStyle.regular(size: 12.sp, color: Colors.grey)),
                    SizedBox(height: 25.h),
                    Text(
                      'LootBazar is a premium B2B marketplace designed to connect bulk sellers and buyers seamlessly. Find the best lots, deal of the day, and much more at your fingertips.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.regular(size: 14.sp, color: Colors.black87, height: 1.5),
                    ),
                    SizedBox(height: 35.h),
                    
                    // Connect Section
                    _buildInfoSection('Connect With Us', [
                      _infoTile(Icons.email_outlined, 'Email', 'support@lootbazar.com', onTap: () {}),
                      _infoTile(Icons.language_rounded, 'Website', 'www.lootbazar.com', onTap: () {}),
                    //  _infoTile(Icons.location_on_outlined, 'Head Office', 'Agra, Uttar Pradesh', onTap: null),
                    ]),
                    
                    SizedBox(height: 25.h),
                    
                    // Legal Section
                    _buildInfoSection('App Information', [
                      _infoTile(Icons.description_outlined, 'Terms & Conditions', 'Read our terms of service', onTap: () {}),
                      _infoTile(Icons.privacy_tip_outlined, 'Privacy Policy', 'How we handle your data', onTap: () {}),
                    ]),
                    
                    SizedBox(height: 40.h),
                    Text(
                      'Made with ❤️ in LootBazar',
                      style: AppTextStyle.medium(size: 12.sp, color: Colors.grey.shade400),
                    ),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.bold(size: 16.sp, color: AppTheme.primary)),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 20.sp),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyle.medium(size: 13.sp, color: Colors.grey.shade600)),
                  Text(value, style: AppTextStyle.semiBold(size: 14.sp, color: Colors.black87)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios_rounded, size: 12.sp, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       /* Text('Settings', style: AppTextStyle.bold(size: 16.sp, color: Colors.black54)),
        SizedBox(height: 15.h),
        _menuCard([
          _menuItem(Icons.location_on_rounded, 'My Address', _addressController.text.isEmpty ? 'Tap to edit' : _addressController.text, 
            onTap: () => setState(() => _isEditing = true)),
          _menuItem(Icons.list_alt_rounded, 'My Listings', 'View and manage your products', 
            onTap: () => context.pushNamed(AppRoutes.myListing)),
        ]),
        SizedBox(height: 25.h),*/
        Text('About & Support', style: AppTextStyle.bold(size: 16.sp, color: Colors.black54)),
        SizedBox(height: 15.h),
        _menuCard([
          _menuItem(Icons.info_outline_rounded, 'About Us', 'Learn more about LootBazar', onTap: _showAboutUsSheet),
          _menuItem(Icons.logout_rounded, 'Logout', 'Sign out from your account', 
            textColor: Colors.red, iconColor: Colors.red, onTap: _showLogoutDialog),
        ]),
      ],
    );
  }

  Widget _menuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: children),
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle, {VoidCallback? onTap, Color? textColor, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: (iconColor ?? AppTheme.primary).withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor ?? AppTheme.primary, size: 22.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyle.semiBold(size: 15.sp, color: textColor ?? Colors.black)),
                  Text(subtitle, style: AppTextStyle.regular(size: 12.sp, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
