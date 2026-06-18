// lib/screens/StoryScreen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/Products/ProductModel.dart';
import 'package:lootbazarweb/providerd/Products/ProductState.dart';
import 'package:lootbazarweb/providerd/video/VideoListResponse.dart';
import 'package:lootbazarweb/shared/story_whatsapp_buttons.dart';
import 'package:story_view/story_view.dart';

class StoryScreen extends StatefulWidget {
  final List<VideoItem> videos;
  final int initialIndex;
  final VideoProduct productModel;

  const StoryScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    required this.productModel,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late final StoryController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _controller = StoryController();
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  VideoItem get _current => widget.videos[_currentIndex];

  // ── setState build phase ke bahar call karo ──
  void _onStoryShow(StoryItem storyItem, int index) {
    final newIndex =
        (widget.initialIndex + index) % widget.videos.length;
    if (_currentIndex != newIndex) {
      // Build phase complete hone ke baad update karo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentIndex = newIndex;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ── Story View ──
              StoryView(
                controller: _controller,
                onStoryShow: _onStoryShow, // ← fixed callback
                onComplete: () {
                  if (mounted) Navigator.pop(context);
                },
                progressPosition: ProgressPosition.top,
                indicatorColor: Colors.white30,
                indicatorForegroundColor: AppTheme.primary,
                repeat: false,
                inline: false,
                storyItems: widget.videos
                    .skip(widget.initialIndex)
                    .map(
                      (v) => StoryItem.pageVideo(
                    v.video,
                    controller: _controller,
                    imageFit: BoxFit.contain,
                    duration: Duration(seconds: v.durationSeconds),
                  ),
                )
                    .toList(),
              ),

              // ── Top bar: back + user info ──
              Positioned(
                top: 16.h,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // User avatar
                      ClipOval(
                        child: SizedBox(
                          width: 38.w,
                          height: 38.w,
                          child:
                          _current.user?.profileImage.isNotEmpty == true
                              ? CachedNetworkImage(
                            imageUrl: _current.user!.profileImage,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                                color: Colors.grey.shade800),
                            errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.shade800),
                          )
                              : Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // User name + product title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _current.user?.name ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_current.product?.title.isNotEmpty == true)
                              Text(
                                _current.product!.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.sp,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Duration badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${_current.durationSeconds}s',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom WhatsApp button ──
              Positioned(
                bottom: 40.h,
                left: 12.w,
                right: 12.w,
                child: StoryWhatsappButtons(
                  location: widget.productModel.location??'',
                  moq: widget.productModel.moq.toString()??'',
                  price: widget.productModel.price.toString()??'',
                  stock: widget.productModel.stock.toString()??'',
                  title:widget.productModel.title??'' ,
                  onTap: () {},
                 // text: _current.product?.title ?? '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}