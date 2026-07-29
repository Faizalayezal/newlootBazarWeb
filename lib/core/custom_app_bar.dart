import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../shared/app_text_style.dart';

class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String svgPath;
  final bool? iconEnable;

  CustomAppBar({
    super.key,
    required this.title,
    required this.svgPath,
    this.iconEnable = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(50.sp);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: preferredSize.height,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            iconEnable==true?Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: (){
                  context.pop();
                },
                child: SvgPicture.asset(
                  svgPath,
                  height: 36.h,
                  width: 36.w,
                ),
              ),
            ):SizedBox.shrink(),
            Center(
              child: Text(
                title,
                style: AppTextStyle.medium(
                  size: 16.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}