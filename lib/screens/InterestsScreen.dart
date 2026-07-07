import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/category/CategoryNotifier.dart';
import 'package:lootbazarweb/providerd/register/RegisterNotifier.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/shared/AnimatedCategoryCard.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:lootbazarweb/shared/PremiumLoadingButton.dart';

class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen>  with SingleTickerProviderStateMixin  {


  List<Color> assignedColors = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadData();
    });
  }
  void _assignColors(int count) {
    if (assignedColors.length != count) {
      assignedColors = List.generate(
        count,
            (index) => AppTheme.pastelColors[index % AppTheme.pastelColors.length],
      );
    }
  }
  Future<void> _loadData() async {
    await ref.read(categoryProvider.notifier).loadCachedCategories();
  }


  @override
  Widget build(BuildContext context) {

    final categoryState = ref.watch(categoryProvider);
    final categories = categoryState.data;
    if (assignedColors.length != categories.length) {
      _assignColors(categories.length);
    }

    debugPrint('Get Categories 64: ${categories.length}');
    final selectedIds = categoryState.selectedIds;
    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      bottomSheet:  Container(
        color: AppTheme.background,
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 40.h),
          child: Consumer(
            builder: (context, ref, child) {
              final registerState = ref.watch(registerProvider);
              return PremiumLoadingButton(
                isLoading: registerState.isLoading,
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final categoryNotifier = ref.read(categoryProvider.notifier);
                  final registerNotifier = ref.read(registerProvider.notifier);

                  // Save locally
                  await categoryNotifier.saveCategoryOnLocal();

                  // Validation
                  final selectedCategoryIds =
                  categoryNotifier.getSelectedCategoryIds();

                  if (selectedCategoryIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select at least one interest"),
                      ),
                    );
                    return;
                  }

                  // API Call
                  await registerNotifier.updateProfile();

                  final state = ref.read(registerProvider);

                  if (state.isSuccess) {
                    if (context.mounted) {
                      context.goNamed(AppRoutes.homeScreen);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.errorMessage ?? "Profile update failed",
                          ),
                        ),
                      );
                    }
                  }
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  60.verticalSpace,
                  Text(
                    'Pick your interests !',
                    style: AppTextStyle.semiBold(
                      size: 34.sp,
                      height: 1.0,
                      color: Colors.black,
                    ),
                  ),
                  14.verticalSpace,
                  Text(
                    'What Categories Are You Into?',
                    style: AppTextStyle.light(
                      size: 12.sp,
                      color: Colors.black,
                    ),
                  ),
                  30.verticalSpace,

                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 1.9,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedIds.contains(category.id);
                      return AnimatedCategoryCard(
                        title: category.name,
                        image: category.image,
                        color: assignedColors[index],
                        delay: index * 100,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(categoryProvider.notifier).toggleSelection(category.id);
                        },
                      );
                    },
                  ),
                  150.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
