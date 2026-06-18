import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/Products/ProductModel.dart';
import 'package:lootbazarweb/providerd/di/sharedPrefsProvider.dart';
import 'package:lootbazarweb/providerd/productDetail/ProductDetailNotifier.dart';
import 'package:lootbazarweb/providerd/productDetail/UploadVideoResponse.dart';
import 'package:lootbazarweb/providerd/productDetail/product_detail_model.dart';
import 'package:lootbazarweb/providerd/productDetail/product_detail_state.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:lootbazarweb/shared/enquire.dart';
import 'package:lootbazarweb/shared/product_card.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';
import 'package:shimmer/shimmer.dart';

import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

// lib/screens/product_detail/product_detail_screen.dart

/*class ProductDetailScreen extends ConsumerStatefulWidget {
  final String? productId;

  const ProductDetailScreen({super.key, this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late PageController _pageController;
  final ValueNotifier<int> _currentImageIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetail();
    });
  }

  void _loadDetail() {
    if (widget.productId == null) return;
    ref.read(productDetailProvider.notifier).getProductDetail(
      productId: widget.productId!,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentImageIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailProvider);
    final product = state.product;
    final images = product?.images ?? [];

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black45,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            // ─── Top Image Section ───
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Image PageView
                state.isLoading
                    ? _buildImageShimmer()
                    : images.isNotEmpty
                    ? SizedBox(
                  height: 0.52.sh,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (i) =>
                    _currentImageIndex.value = i,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index].url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Image.asset(
                              'assets/images/splashlogo.png',
                              fit: BoxFit.cover,
                            ),
                      );
                    },
                  ),
                )
                    : Container(
                  height: 0.52.sh,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported,
                      size: 60, color: Colors.grey),
                ),

                // Image dot indicator
                if (images.length > 1)
                  Positioned(
                    bottom:25.h,
                    left: 0,
                    right: 0,
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentImageIndex,
                      builder: (context, currentIndex, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                                (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                              width: i == currentIndex ? 12 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == currentIndex
                                    ? AppTheme.primary
                                    : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Back button
                Positioned(
                  top: 0.050.sh,
                  left: 0.025.sw,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: AppTheme.primary),
                    ),
                  ),
                ),

                // Share button
                Positioned(
                  top: 0.050.sh,
                  right: 0.025.sw,
                  child: GestureDetector(
                    onTap: () {
                      final link = 'https://lootbazar.com/details/${widget.productId}';
                     // Share.share(link);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset("assets/images/share.svg"),
                    ),
                  ),
                ),
              ],
            ),

            // ─── Draggable Bottom Sheet ───
            DraggableScrollableSheet(
              initialChildSize: 0.48,
              minChildSize: 0.48,
              maxChildSize: 0.9,
              builder: (context, controller) => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: state.isLoading
                    ? _buildDetailShimmer()
                    : state.errorMessage != null
                    ? _buildError()
                    : SingleChildScrollView(
                  controller: controller,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40.w,
                            height: 4.h,
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius:
                              BorderRadius.circular(2.r),
                            ),
                          ),
                        ),

                        // Thumbnail image list
                        if (images.isNotEmpty)
                          SizedBox(
                            height: 60.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(
                                      index,
                                      duration: const Duration(
                                          milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: ValueListenableBuilder<int>(
                                    valueListenable:
                                    _currentImageIndex,
                                    builder: (context, currentIndex,
                                        child) {
                                      final isSelected =
                                          index == currentIndex;
                                      return Container(
                                        margin: EdgeInsets.only(
                                            right: 8.w),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected
                                                ? AppTheme.primary
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(
                                              8.r),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(
                                              6.r),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                            images[index].url,
                                            height: 56.h,
                                            width: 56.w,
                                            fit: BoxFit.cover,
                                            placeholder: (c, u) =>
                                                Container(
                                                    color: Colors
                                                        .grey.shade200),
                                            errorWidget: (c, u, e) =>
                                                Image.asset(
                                                  'assets/images/splashlogo.png',
                                                  fit: BoxFit.cover,
                                                ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),

                        SizedBox(height: 16.h),

                        // Title
                        Text(
                          product?.title ?? '',
                          style: AppTextStyle.bold(
                              size: 18.sp, color: Colors.black),
                        ),
                        SizedBox(height: 8.h),

                        // Description
                        Text(
                          product?.description ?? '',
                          style: AppTextStyle.regular(
                              size: 13.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 24.h),

                        // Stats Row
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            _statColumn(
                                '₹ ${product?.price.toStringAsFixed(0) ?? ''}',
                                'Rate'),
                            _statColumn(
                                product?.stock.toString() ?? '',
                                'Pcs'),
                            _statColumn(
                                product?.moq.toString() ?? '', 'MOQ'),
                            _statColumn(
                                product?.location ?? '-', 'Location'),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // WhatsApp Button
                        WhatsappButtons(
                          onTap: () async {
                            final phone = product?.phoneNumber ?? '';
                            final desc = product?.description ?? '';
                            final url =
                                'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(desc)}';
                            // commonLaunchUrl(url);
                          },
                          location: product?.location ?? '',
                          productDesc: product?.description ?? '',
                        ),
                        SizedBox(height: 16.h),

                        // Similar Listing header
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Similar Listing",
                              style: AppTextStyle.regular(
                                  color: Colors.black),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "View all",
                                style: AppTextStyle.regular(
                                  size: 13.sp,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        // Similar products grid
                        // ⚠️ Apna existing getProductResponse aur
                        // isProductLoading yahan use karo
                        Consumer(
                          builder: (context, ref, child) {
                            final productState =
                            ref.watch(productProvider);
                            final isProductLoading =
                                productState.isLoading;
                            final products =
                                productState.products ?? [];

                            return GridView.builder(
                              padding: EdgeInsets.zero,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 1.4 / 2,
                              ),
                              itemCount: isProductLoading
                                  ? 4
                                  : products.length > 4
                                  ? 4
                                  : products.length,
                              itemBuilder: (context, index) {
                                if (isProductLoading) {
                                  return ProductShimmerCard();
                                }
                                final p = products[index];
                                return ProductCard(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetailScreen(
                                              productId: p.id,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Stat Column Widget ───
  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyle.bold(size: 16.sp)),
        SizedBox(height: 4.h),
        Text(label, style: AppTextStyle.regular(size: 12.sp)),
      ],
    );
  }

  // ─── Image Shimmer (top section) ───
  Widget _buildImageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 0.52.sh,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }

  // ─── Detail Shimmer (bottom sheet) ───
  Widget _buildDetailShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail shimmer
            Row(
              children: List.generate(
                4,
                    (i) => Container(
                  margin: EdgeInsets.only(right: 8.w),
                  height: 56.h,
                  width: 56.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Title shimmer
            Container(
              height: 20.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 12.h),
            // Description shimmer
            Container(
              height: 14.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 14.h,
              width: 0.6.sw,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 24.h),
            // Stats shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                    (i) => Column(
                  children: [
                    Container(
                      height: 18.h,
                      width: 50.w,
                      color: Colors.white,
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      height: 12.h,
                      width: 35.w,
                      color: Colors.white,
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

  // ─── Error Widget ───
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 12.h),
            Text(
              'Failed to load product',
              style: AppTextStyle.bold(size: 16.sp),
            ),
            SizedBox(height: 8.h),
            MainButton(
              onTap: _loadDetail,
              text: 'Retry',
            ),
          ],
        ),
      ),
    );
  }
}*/



// product_detail_screen.dart

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String? productId;
  final String? currentUserId; // ← pass karo login user ki id
  const ProductDetailScreen({
    super.key,
    this.productId,
    this.currentUserId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  final ImagePicker _picker = ImagePicker();

  // Current logged-in user ID — SharedPrefs se load karo
  String? _myUserId;

  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetail();
      _loadMyUserId();
    });
  }

  Future<void> _loadMyUserId() async {
    final prefs = ref.read(sharedPrefsProvider);
    final id = await prefs.getString(userId);
    if (mounted) setState(() => _myUserId = id);
  }

  void _loadDetail() async {
    if (widget.productId == null) return;
    await ref
        .read(productDetailProvider.notifier)
        .getProductDetail(productId: widget.productId!);
    await ref.read(productDetailProvider.notifier).trackView(
      productId: widget.productId ?? '',
      type: 'view',
    );

    final product = ref.read(productDetailProvider).product;
    if (product != null && product.createdAt != null) {
      _startCountdown(DateTime.parse(product.createdAt));
    }
  }
  void _startCountdown(DateTime createdAt) {
    _countdownTimer?.cancel();

    void updateRemaining() {
      final expiryTime = createdAt.add(const Duration(hours: 24));
      final now = DateTime.now();
      final diff = expiryTime.difference(now);

      if (!mounted) return;
      setState(() {
        _remainingTime = diff.isNegative ? Duration.zero : diff;
      });

      // Stop timer once expired
      if (diff.isNegative) {
        _countdownTimer?.cancel();
      }
    }

    updateRemaining(); // set initial value immediately
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateRemaining();
    });
  }

  // ── Format Duration as HH:MM:SS ──
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _pickAndUploadImage() async {
    // Multiple images support
    final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty || widget.productId == null || _myUserId == null) return;

    for (final image in picked) {
      await ref.read(productDetailProvider.notifier).uploadImage(
        productId: widget.productId!,
        imageFile: image,
      );
    }

    final state = ref.read(productDetailProvider);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.isImageUploadSuccess
              ? '${picked.length} image(s) uploaded successfully!'
              : 'Upload failed: ${state.imageUploadError}',
        ),
        backgroundColor:
        state.isImageUploadSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Is current user owner? ──
  bool get _isOwner {
    final product = ref.read(productDetailProvider).product;
    if (_myUserId == null || product == null) return false;
    return product.userId == _myUserId;
  }

  Future<void> _pickAndUploadVideo() async {
    final XFile? picked =
    await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null || widget.productId == null) return;

    await ref.read(productDetailProvider.notifier).uploadVideo(
      productId: widget.productId!,
      videoFile: XFile(picked.path),
    );

    final state = ref.read(productDetailProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.isVideoUploadSuccess
            ? 'Video uploaded successfully!'
            : 'Upload failed: ${state.videoUploadError}'),
        backgroundColor:
        state.isVideoUploadSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  void _openVideoPlayer(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  // ── Delete image confirm dialog ──
  Future<void> _confirmDeleteImage(String imageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ref.read(productDetailProvider.notifier).deleteImage(
        productId: widget.productId!,
        imageId: imageId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted'),
            backgroundColor: Colors.green,
          ),
        );
        // PageController reset karo agar last image delete hui
        setState(() => _currentImageIndex = 0);
        _pageController.jumpToPage(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Delete video confirm dialog ──
  Future<void> _confirmDeleteVideo(String videoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Video'),
        content: const Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ref.read(productDetailProvider.notifier).deleteVideo(
        videoId: videoId,
        productId: widget.productId!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailProvider);
    final product = state.product;
    final callList = state.viewers?.call ?? [];
    final viewList = state.viewers?.view ?? [];
    final similarList = state.similarProducts ?? [];
    final images = product?.images ?? [];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: state.isLoading
            ? _buildShimmer()
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. Top Image Carousel ───
              Stack(
                children: [
                  Container(
                    height: 380.h,
                    color: const Color(0xFFFFE6DC),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index].url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFFFD9CC),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // ── Owner hone par image pe delete button ──
                  if (_isOwner && images.isNotEmpty)
                    Positioned(
                      top: 50.h,
                      right: 20.w,
                      child: _buildDeleteImageButton(
                        imageId: images[_currentImageIndex].id,
                        isDeleting: state.isDeletingImage &&
                            state.deletingImageId ==
                                images[_currentImageIndex].id,
                      ),
                    ),
                  // Dots
                  Positioned(
                    bottom: 20.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (i) {
                        bool isActive =
                            (i % images.length) == _currentImageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin:
                          EdgeInsets.symmetric(horizontal: 2.w),
                          width: isActive ? 10.w : 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFFF5722)
                                : const Color(0xFFFDC1AB),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: 50.h,
                    left: 20.w,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5722),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ─── 2. Thumbnails Row ───
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 14.h, horizontal: 16.w),
                child: SizedBox(
                  height: 64.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Image thumbnails
                      ...List.generate(
                        images.length,
                            (index) => _buildImageThumbnail(
                            images, index, state),
                      ),

                      // Video thumbnails
                      if (state.videos.isNotEmpty)
                        ...state.videos.map(
                              (video) => _buildVideoThumbnail(
                              video, state),
                        ),

                      // Uploading shimmer
                      if (state.isVideoUploading)
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            margin: EdgeInsets.only(right: 8.w),
                            width: 62.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius:
                              BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      if (state.isUploadingImage)
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            margin: EdgeInsets.only(right: 8.w),
                            width: 62.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),



              // ─── 3. Action Badges ───
              if(_isOwner)...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: state.isVideoUploading
                            ? null
                            : _pickAndUploadVideo,
                        child: _buildActionBadge(
                          icon: state.isVideoUploading
                              ? Icons.hourglass_top_rounded
                              : Icons.cases_outlined,
                          label: state.isVideoUploading
                              ? 'Uploading...'
                              : 'Add Video',
                          bgColor: AppTheme.card,
                          textColor: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildActionBadge(
                        icon: Icons.access_time_outlined,
                        label: _remainingTime == Duration.zero
                            ? 'Expired'
                            : _formatDuration(_remainingTime),
                        bgColor: AppTheme.card,
                        textColor: Colors.black,
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: state.isUploadingImage ? null : _pickAndUploadImage,
                        child: _buildActionBadge(
                          icon: state.isUploadingImage
                              ? Icons.hourglass_top_rounded
                              : Icons.camera_alt_outlined,
                          label: state.isUploadingImage ? 'Uploading...' : 'Add images',
                          bgColor: AppTheme.card,
                          textColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],


              // ─── 4. Title ───
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  product?.title ?? '',
                  style: AppTextStyle.regular(
                    size: 18.sp,
                    height: 1.25,
                    color: const Color(0xFF202020),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // ─── 5. Stats Row ───
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatCol(
                          '₹${product?.price ?? ''}', 'Rate'),
                      SizedBox(width: 42.w),
                      _buildStatCol(
                          '${product?.stock ?? ''}', 'Quantity'),
                      SizedBox(width: 42.w),
                      _buildStatCol(
                          '${product?.moq ?? ''}', 'MOQ'),
                      SizedBox(width: 42.w),
                      _buildStatCol(
                          '${product?.location ?? ''}', 'Location'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // ─── 6. WhatsApp Card ───
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: WhatsappBusinessCard(
                  sellerName: product?.description ?? '',
                  sellerLocation: product?.location ?? '',
                  onTap: () {
                    ref
                        .read(productDetailProvider.notifier)
                        .trackView(
                      productId: widget.productId ?? '',
                      type: 'call',
                    );
                  },
                ),
              ),

              if (callList.isNotEmpty) ...[
                SizedBox(height: 24.h),
                _buildSectionHeader('Enquiries'),
                EnquiryList(isLead: false, viewers: callList),
              ],
              if (viewList.isNotEmpty) ...[
                SizedBox(height: 16.h),
                _buildSectionHeader('Leads'),
                EnquiryList(isLead: false, viewers: viewList),
              ],
              if (similarList.isNotEmpty) ...[
                SizedBox(height: 24.h),
                _buildSectionHeader('Your listings'),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding:
                    EdgeInsets.only(top: 8.h, bottom: 40.h),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.74,
                    ),
                    itemCount: similarList.length,
                    itemBuilder: (context, index) {
                      final p = similarList[index];
                      return ProductCard(
                        imageUrl: p.images.isNotEmpty
                            ? p.images.first.url
                            : '',
                        title: p.title,
                        rate: p.price.toString(),
                        pcs: p.stock.toString(),
                        moq: p.moq.toString(),
                        location: p.location ?? '',
                        onTap: () {
                          context.pushNamed(
                            AppRoutes.productDetail,
                            extra: {'productId': p.id},
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image thumbnail with delete ──
  Widget _buildImageThumbnail(
      List<ProductDetailImage> images, int index, ProductDetailState state) {
    final isDeleting = state.isDeletingImage &&
        state.deletingImageId == images[index].id;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: index == _currentImageIndex
                ? AppTheme.primary
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: CachedNetworkImage(
                imageUrl: images[index].url,
                width: 62.w,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (c, u) =>
                    Container(color: Colors.grey.shade200),
                errorWidget: (c, u, e) => Image.asset(
                  'assets/images/splashlogo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Delete button — owner hone par
            if (_isOwner)
              Positioned(
                top: 2.h,
                right: 2.w,
                child: isDeleting
                    ? Container(
                  width: 18.w,
                  height: 18.w,
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white,
                  ),
                )
                    : GestureDetector(
                  onTap: () =>
                      _confirmDeleteImage(images[index].id),
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 10.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Video thumbnail with delete ──
  Widget _buildVideoThumbnail(
      ProductVideo video, ProductDetailState state) {
    final isDeleting = state.isDeletingVideo &&
        state.deletingVideoId == video.id;

    return GestureDetector(
      onTap: isDeleting ? null : () => _openVideoPlayer(video.video),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        width: 62.w,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFF5722),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(color: const Color(0xFF1A1A1A)),
              // Loading overlay
              if (isDeleting)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else ...[
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5722),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
                Positioned(
                  bottom: 4.h,
                  child: Text(
                    'VIDEO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Delete button — owner hone par
                if (_isOwner)
                  Positioned(
                    top: 2.h,
                    right: 2.w,
                    child: GestureDetector(
                      onTap: () => _confirmDeleteVideo(video.id),
                      child: Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 10.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Delete image button (carousel pe) ──
  Widget _buildDeleteImageButton({
    required String imageId,
    required bool isDeleting,
  }) {
    return GestureDetector(
      onTap: isDeleting ? null : () => _confirmDeleteImage(imageId),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: isDeleting
            ? SizedBox(
          width: 18.w,
          height: 18.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 18.sp,
        ),
      ),
    );
  }

  // ── Shimmer, badges, stat col, section header — same as before ──
  // ── Shimmer loading UI — same layout structure as real content ──
  Widget _buildShimmer() {
    Widget shimmerBox({
      double? width,
      double? height,
      BorderRadius? borderRadius,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius ?? BorderRadius.circular(6.r),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Top image carousel placeholder ───
            shimmerBox(
              width: double.infinity,
              height: 380.h,
              borderRadius: BorderRadius.zero,
            ),

            // ─── 2. Thumbnails row placeholder ───
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              child: SizedBox(
                height: 64.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, __) => shimmerBox(
                    width: 62.w,
                    height: 64.h,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),

            // ─── 3. Action badges placeholder ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  shimmerBox(
                    width: 96.w,
                    height: 30.h,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  SizedBox(width: 8.w),
                  shimmerBox(
                    width: 80.w,
                    height: 30.h,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  SizedBox(width: 8.w),
                  shimmerBox(
                    width: 90.w,
                    height: 30.h,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // ─── 4. Title placeholder ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: shimmerBox(
                width: double.infinity,
                height: 18.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: shimmerBox(
                width: 180.w,
                height: 18.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 20.h),

            // ─── 5. Stats row placeholder ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shimmerBox(
                          width: 50.w,
                          height: 22.h,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        SizedBox(height: 6.h),
                        shimmerBox(
                          width: 40.w,
                          height: 11.h,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 24.h),

            // ─── 6. WhatsApp card placeholder ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: shimmerBox(
                width: double.infinity,
                height: 80.h,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 24.h),

            // ─── 7. Section header + grid placeholder ───
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
              child: shimmerBox(
                width: 120.w,
                height: 16.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 8.h, bottom: 40.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.74,
                ),
                itemCount: 4,
                itemBuilder: (_, __) => shimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionBadge({required IconData icon, required String label, required Color bgColor, required Color textColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14.sp, color: textColor),
        SizedBox(width: 4.w),
        Text(label, style: AppTextStyle.regular(size: 12.sp, color: textColor)),
      ]),
    );
  }
  Widget _buildStatCol(String val, String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(val, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A1A))),
      SizedBox(height: 4.h),
      Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w400, color: Colors.grey.shade500)),
    ]);
  }
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h, bottom: 8.h),
      child: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
    );
  }
}

class _VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerScreen({required this.videoUrl});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.play();
        setState(() => _isPlaying = true);
      });
    _controller.addListener(() {
      if (_controller.value.isPlaying != _isPlaying) {
        setState(() => _isPlaying = _controller.value.isPlaying);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Video', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _isInitialized
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Video player
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            SizedBox(height: 16.h),
            // Progress bar
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (_, VideoPlayerValue value, __) {
                final position = value.position;
                final duration = value.duration;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFFFF5722),
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            // Play/Pause button
            GestureDetector(
              onTap: () {
                _isPlaying ? _controller.pause() : _controller.play();
              },
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5722),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),
            ),
          ],
        )
            : const CircularProgressIndicator(color: Color(0xFFFF5722)),
      ),
    );
  }
}
