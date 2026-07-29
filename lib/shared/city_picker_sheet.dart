import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lootbazarweb/core/theme.dart';
import '../providerd/city_state.dart';
import 'app_text_style.dart';

class CityPickerSheet extends ConsumerStatefulWidget {
  const CityPickerSheet();

  @override
  ConsumerState<CityPickerSheet> createState() => CityPickerSheetState();
}

class CityPickerSheetState extends ConsumerState<CityPickerSheet> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  String query = '';

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _selectCity(String city) {
    // Unfocus search field BEFORE popping, so focus doesn't jump
    // to the next focusable field on the screen behind the sheet.
    searchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context, city);
  }

  @override
  Widget build(BuildContext context) {
    final cityState = ref.watch(cityProvider);

    final filtered = query.isEmpty
        ? cityState.cities
        : cityState.cities
        .where((c) => c.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, (1 - value) * 60),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Material(
            // ✅ Material instead of plain decorated Container
            color: Colors.white,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
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
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select your city',
                          style: AppTextStyle.semiBold(
                              size: 18.sp, color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close,
                              size: 22.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      autofocus: true,
                      onChanged: (val) => setState(() => query = val),
                      decoration: InputDecoration(
                        hintText: 'Search city...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.orange.withOpacity(0.06),
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: _buildListArea(cityState, filtered),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListArea(CityState cityState, List<String> filtered) {
    if (cityState.isLoading && cityState.cities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cityState.error != null && cityState.cities.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text('Could not load cities',
                style: AppTextStyle.light(size: 13.sp, color: Colors.grey)),
            TextButton(
              onPressed: () =>
                  ref.read(cityProvider.notifier).loadCities(force: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Text('No city found',
            style: AppTextStyle.light(size: 14.sp, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final city = filtered[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 200 + (index % 10) * 20),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 12),
                child: child,
              ),
            );
          },
          // ✅ ListTile now properly inherits ink/ripple from the
          // Material wrapper above — no more warning.
          child: ListTile(
            leading: Icon(Icons.location_on_outlined,
                color: AppTheme.primary, size: 20.sp),
            title: Text(city,
                style: AppTextStyle.semiBold(size: 15.sp, color: Colors.black)),
            onTap: () => _selectCity(city),
          ),
        );
      },
    );
  }
}