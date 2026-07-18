// lib/screens/notification/notification_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lootbazarweb/providerd/notification/NotificationNotifier.dart';
import 'package:lootbazarweb/providerd/notification/NotificationProduct.dart';
import 'package:lootbazarweb/utils/AppLauncher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lootbazarweb/core/CustomAppBar.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:lootbazarweb/shared/EmptyStateWidget.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => ref.read(notificationProvider.notifier).getNotifications(),
    );
  }

  // ── Time ago format ──────────────────────────────────────────────────────
  String _timeAgo(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            title: "Notifications",
            svgPath: "assets/images/backbtn.svg",
            iconEnable: false,
          ),
          body: RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () =>
                ref.read(notificationProvider.notifier).refresh(),
            child: _buildBody(state),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(state) {
    // ── Shimmer loading ──────────────────────────────────────────────────
    if (state.isLoading) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        itemCount: 6,
        itemBuilder: (_, __) => _buildShimmerItem(),
      );
    }

    // ── Error ────────────────────────────────────────────────────────────
    if (state.errorMessage != null && state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmptyStateWidget(
              title: 'Failed to load notifications',
              subtitle: 'Please check your connection and try again.',
              icon: Icons.wifi_off_rounded,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () =>
                  ref.read(notificationProvider.notifier).getNotifications(),
              child: Text(
                'Retry',
                style: AppTextStyle.bold(color: AppTheme.primary),
              ),
            ),
          ],
        ),
      );
    }

    // ── Empty ────────────────────────────────────────────────────────────
    if (state.notifications.isEmpty) {
      return const EmptyStateWidget(
        title: 'No notifications yet',
        subtitle: 'We\'ll notify you when someone views or enquiries about your products.',
        icon: Icons.notifications_none_rounded,
      );
    }

    // ── List ─────────────────────────────────────────────────────────────
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      itemCount: state.notifications.length,
      itemBuilder: (context, index) {
        final notification = state.notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  // ── Single notification tile ─────────────────────────────────────────────
  Widget _buildNotificationItem(NotificationModel n) {
    final isCall = n.type == 'call';
    final imageUrl = n.product.images.isNotEmpty ? n.product.images.first : '';

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 8.h),
          child: Container(
            constraints: BoxConstraints(minHeight: 60.h),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
              border: Border.all(
                color: const Color(0xFFFFDCD0).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Product image ──────────────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    width: 70.w,
                    height: 120.h,
                    color: Colors.grey[100],
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[200],
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.image_not_supported,
                                  size: 20, color: Colors.grey[400]),
                            ),
                          )
                        : Icon(Icons.inventory_2_outlined,
                                size: 24, color: Colors.grey[400]),
                  ),
                ),
                SizedBox(width: 12.w),

                // ── Text content ───────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 6.h, bottom: 6.h, right: 10.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type badge + time
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: isCall
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isCall
                                        ? Icons.phone_outlined
                                        : Icons.visibility_outlined,
                                    size: 11.sp,
                                    color: isCall
                                        ? Colors.green[700]
                                        : Colors.blue[700],
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    isCall ? 'Enquiry' : 'View',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isCall
                                          ? Colors.green[700]
                                          : Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _timeAgo(n.viewedAt),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[400],
                              ),
                            ),
                            // Unread dot
                            if (!n.isRead) ...[
                              SizedBox(width: 6.w),
                              Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ]
                          ],
                        ),
                        SizedBox(height: 6.h),

                        // Viewer name
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(
                                fontSize: 13.sp, color: const Color(0xFF1A1A1A)),
                            children: [
                              TextSpan(
                                text: n.viewer.name.isNotEmpty
                                    ? n.viewer.name
                                    : 'Someone',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: isCall
                                    ? ' enquired about your product'
                                    : ' viewed your product',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),

                        // Product title
                        Text(
                          n.product.title,
                          style: AppTextStyle.regular(
                            size: 13.sp,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Viewer location
                        if (n.viewer.address.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 11.sp, color: Colors.grey[400]),
                              SizedBox(width: 2.w),
                              Text(
                                '${n.viewer.address}, ${n.viewer.pincode}',
                                style: TextStyle(
                                    fontSize: 11.sp, color: Colors.grey[400]),
                              ),


                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 13.h,
          right: 12.w,
          child:  Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366), // Solid WhatsApp Green
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: GestureDetector(
              onTap: (){
                AppLauncher.openWhatsApp(
                  phone: n.viewer.mobileNo,
                );
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/chaticon.png",
                    height: 16.h,
                    width: 16.w,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Chat now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),


      ],
    );
  }

  // ── Shimmer item ─────────────────────────────────────────────────────────
  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(width: 12.w),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 40.w,
                        height: 11.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    height: 13.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    width: 120.w,
                    height: 12.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    width: 80.w,
                    height: 11.h,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}