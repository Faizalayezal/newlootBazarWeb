import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lootbazarweb/providerd/productDetail/product_detail_model.dart';
import 'package:lootbazarweb/utils/AppLauncher.dart';

class EnquiryList extends StatelessWidget {
  final bool isLead;
  final List<ProductViewer>? viewers;


  const EnquiryList({super.key, required this.isLead,this.viewers});

  @override
  Widget build(BuildContext context) {

    if(viewers?.isEmpty??false){
      return SizedBox.shrink();
    }


    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      itemCount: viewers?.length,
      itemBuilder: (context, index) {
        final entry = viewers?[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              // 1. Customized Pinkish Outline Avatar Frame
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE0C4C8),
                    width: 1.w,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.grey.shade500,
                    size: 20.r,
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              // 2. Expandable Info block (Name + Time + Loc)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                entry?.name??'',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '${entry?.time??''} • ${entry?.address??''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // 3. Compact Green WhatsApp Quick Trigger Button
              GestureDetector(
                onTap: () {
                  AppLauncher.openWhatsApp(
                    phone: entry?.phoneNumber??'',
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366), // Solid WhatsApp Green
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/chaticon.png",
                        height: 18.h,
                        width: 18.w,
                        fit: BoxFit.scaleDown,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Chat now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WhatsappBusinessCard extends StatelessWidget {
  final String sellerName;
  final String sellerLocation;
  final VoidCallback onTap;

  const WhatsappBusinessCard({
    super.key,
    required this.sellerName,
    required this.sellerLocation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Container(
          constraints: BoxConstraints(minHeight: 74.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Safe, solid WhatsApp styled chat logo block (Left Portion)
              Container(
                width: 72.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366), // Formal WhatsApp Green
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    bottomLeft: Radius.circular(10.r),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/chaticon.png",
                      height: 40.h,
                      width: 40.w,
                      fit: BoxFit.scaleDown,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Chat Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
  
              // Expanded detail container (Right Portion) matching screenshot scheme perfectly
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFE9), // Soft orange/peach container background
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.r),
                      bottomRight: Radius.circular(10.r),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sellerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        sellerLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'TRUSTED',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF6B2358), // Signature Burgundy
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.thumb_up_alt,
                            color: const Color(0xFF6B2358),
                            size: 11.sp,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
