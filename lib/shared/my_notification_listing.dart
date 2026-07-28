import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/notification/notification_product.dart';
import 'app_text_style.dart';

class MyNotificationListing extends StatelessWidget {
  final NotificationModel? notification;
  final String? timeAgo;
  const MyNotificationListing(
      {super.key, required this.onTap, this.notification,this.timeAgo});

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.card,
      margin: EdgeInsets.zero,
      elevation: 1,
      shadowColor: Colors.grey,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.r),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
              child: SizedBox(
                width: 100.w,
                child: Image.asset(
                  'assets/images/man.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("intrested Buyer!",
                        style: AppTextStyle.regular(
                          color: Colors.black,
                          size: 15.sp,
                        )),
                    5.verticalSpace,
                    Text(
                        "Imran From Rajkot, Gujarat Recently Viewed you listing",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.regular(
                            color: Colors.black,
                            size: 10.sp)),
                    5.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(
                          'assets/images/notificationchat.svg',
                          height: 25.h,
                        ),
                        Text(timeAgo??'',
                            style: AppTextStyle.regular(
                              color: Colors.black,
                              size: 9.sp,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
