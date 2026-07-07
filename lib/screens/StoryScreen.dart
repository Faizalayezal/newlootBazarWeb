import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lootbazarweb/providerd/video/VideoListResponse.dart';
import 'package:lootbazarweb/shared/story_whatsapp_buttons.dart';
import 'package:lootbazarweb/utils/AppLauncher.dart';
import 'package:video_player/video_player.dart';

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
  late PageController _pageController;
  late int _currentIndex;
  double _dismissProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialIndex,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Black background that fades out as you swipe down
            Positioned.fill(
              child: Opacity(
                opacity: (1 - _dismissProgress * 2.0).clamp(0.0, 1.0),
                child: Container(color: Colors.black),
              ),
            ),
            Dismissible(
              key: const Key('story_screen_dismissible'),
              direction: DismissDirection.down,
              onUpdate: (details) {
                setState(() {
                  _dismissProgress = details.progress;
                });
              },
              onDismissed: (_) => Navigator.pop(context),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.videos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final videoItem = widget.videos[index];
                  // Calculating the 3D cube perspective matrix
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 0.0;
                      if (_pageController.position.haveDimensions) {
                        value = index.toDouble() - (_pageController.page ?? 0);
                      } else {
                        value = index.toDouble() - widget.initialIndex.toDouble();
                      }

                      // Absolute rotation value clamped between -1.57 and 1.57
                      final double rotation = (value * -0.45).clamp(-1.57, 1.57);
                      final bool isLeft = value < 0;

                      return Transform(
                        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0015) // Depth perspective multiplier
                          ..rotateY(rotation),
                        child: child,
                      );
                    },
                    child: _ProductStoryPlayer(
                      key: ValueKey('story_player_${videoItem.id ?? videoItem.hashCode}'),
                      videoItem: videoItem,
                      isActive: index == _currentIndex,
                      onNextStory: () {
                        if (_currentIndex < widget.videos.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      onPrevStory: () {
                        if (_currentIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      onClose: () => Navigator.pop(context),
                      productModel: widget.productModel,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── INDIVIDUAL PRODUCT VIDEO STORY CONTROLLER ──
class _ProductStoryPlayer extends StatefulWidget {
  final dynamic videoItem;
  final bool isActive;
  final VoidCallback onNextStory;
  final VoidCallback onPrevStory;
  final VoidCallback onClose;
  final VideoProduct productModel;

  const _ProductStoryPlayer({
    super.key,
    required this.videoItem,
    required this.isActive,
    required this.onNextStory,
    required this.onPrevStory,
    required this.onClose,
    required this.productModel,
  });

  @override
  State<_ProductStoryPlayer> createState() => _ProductStoryPlayerState();
}

class _ProductStoryPlayerState extends State<_ProductStoryPlayer> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  AnimationController? _progressController;
  bool _isInitialized = false;
  bool _isPaused = false;

  dynamic get user => widget.videoItem.user ?? widget.videoItem.userId;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    final String videoUrl = widget.videoItem.video ?? '';
    if (videoUrl.isEmpty) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
        });

        final duration = _videoController!.value.duration;
        _progressController = AnimationController(
          vsync: this,
          duration: duration,
        );

        _progressController!.addListener(() {
          if (!mounted) return;
          setState(() {});
        });

        _progressController!.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget.onNextStory();
          }
        });

        if (widget.isActive) {
          _playStory();
        }
      }).catchError((error) {
        // Fallback progress controller for images/fails
        _progressController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 5),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget.onNextStory();
          }
        });
        _progressController!.addListener(() {
          setState(() {});
        });
        if (widget.isActive) {
          _progressController!.forward();
        }
      });
  }

  void _playStory() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.play();
    }
    _progressController?.forward();
  }

  void _pauseStory() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.pause();
    }
    _progressController?.stop();
    setState(() => _isPaused = true);
  }

  void _resumeStory() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.play();
    }
    _progressController?.forward();
    setState(() => _isPaused = false);
  }

  @override
  void didUpdateWidget(_ProductStoryPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _playStory();
    } else if (!widget.isActive && oldWidget.isActive) {
      _pauseStory();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _progressController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String location = widget.videoItem.product.location ?? '';
    final String moq = widget.videoItem.product.moq?.toString() ?? '1';
    final String price = widget.videoItem.product.price?.toString() ?? '0';
    final String stock = widget.videoItem.product.stock?.toString() ?? '0';
    final String title = widget.videoItem.product.title ?? 'Product';
    final String phone = widget.videoItem?.user.mobileno ?? user?.mobileno ?? '';

    return Listener(
      onPointerDown: (_) => _pauseStory(),
      onPointerUp: (_) => _resumeStory(),
      onPointerCancel: (_) => _resumeStory(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background player
          Container(
            color: Colors.black,
            child: _isInitialized && _videoController != null
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.productModel.imageUrls != null && widget.productModel.imageUrls.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: widget.productModel.imageUrls[0],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        const CircularProgressIndicator(color: Color(0xFFFF5722)),
                      ],
                    ),
                  ),
          ),

          // Top Segment Progress line
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 12.w,
            right: 12.w,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressController?.value ?? 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top Info Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 22.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onClose,
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12.w),
                ClipOval(
                  child: SizedBox(
                    width: 38.w,
                    height: 38.w,
                    child: user?.profileImage != null && user.profileImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: user.profileImage,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.name ?? 'Seller',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Bottom dynamic details matching current product
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 50.h,
            left: 12.w,
            right: 12.w,
            child: StoryWhatsappButtons(
              location: location,
              moq: moq,
              price: price,
              stock: stock,
              title: title,
              onTap: () {
                AppLauncher.openWhatsApp(
                  phone: phone,
                );
                // Perform WhatsApp launch or call
                //  print("Inquiry regarding: $title via phone: $phone");
              },
            ),
          ),
        ],
      ),
    );
  }
}
