import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';

class UploadProductPhotosButton extends StatelessWidget {

  final Function? onCall;

  const UploadProductPhotosButton({super.key,this.onCall});



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onCall?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10.h,
          horizontal: 14.w,

        ),
        decoration: BoxDecoration(
          color: const Color(0xFF102F47),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Product Photos',
                  style: AppTextStyle.regular(color: AppTheme.secondary),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Upto 20 Photos',
                  style: AppTextStyle.regular(color: Colors.grey,size: 11.sp),
                ),
              ],
            ),
            SvgPicture.asset(
              'assets/images/uploadPhoto.svg',
              height: 30.h,
              width: 30.w,
            ),
          ],
        ),
      ),
    );
  }
}


