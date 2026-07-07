import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/bottomNav/NavBarController.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/Products/ProductNotifier.dart';
import 'package:lootbazarweb/providerd/Products/ProductState.dart';
import 'package:lootbazarweb/providerd/category/CategoryNotifier.dart';
import 'package:lootbazarweb/providerd/register/RegisterNotifier.dart';
import 'package:lootbazarweb/providerd/video/VideoNotifier.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/shared/AnimatedCategoryCard.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:lootbazarweb/shared/StoryCard.dart';
import 'package:lootbazarweb/shared/product_card.dart';
import 'package:lootbazarweb/tool/ProductShimmerCard.dart';
import 'package:lootbazarweb/utils/preferences.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';
import 'package:lootbazarweb/shared/EmptyStateWidget.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  late final ValueNotifier<double> _scrollProgress = ValueNotifier(0.0);

  static const double _collapseBy = 130.0;

  List<Color> assignedColors = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // ✅ Pairs ek baar calculate karo

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadData();
    });

    Future.microtask(() {
      ref.read(productProvider.notifier).getProducts();
      ref.read(videoProvider.notifier).getVideos();
      ref.read(registerProvider.notifier).syncProfile();
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

    final categories = ref.read(categoryProvider).data;

    _assignColors(categories.length);

    if (mounted) {
      setState(() {});
    }
  }

  void _onScroll() {
    // Header collapse animation
    final offset = _scrollController.offset.clamp(0.0, _collapseBy);
    _scrollProgress.value = offset / _collapseBy;

    final direction = _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.reverse &&
        _scrollController.offset > 100) {
      NavBarController.showNavBar.value = false;
    } else if (direction == ScrollDirection.forward) {
      NavBarController.showNavBar.value = true;
    }
  }


  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollProgress.dispose();
    super.dispose();
  }

  Widget _buildHorizontalCategoryGrid() {
    return Consumer(
      builder: (context, ref, child) {
        final categoryState = ref.watch(categoryProvider);
        final categories = categoryState.data;

        final List<List<int>> pairedIndices = [];
        for (int i = 0; i < categories.length; i += 2) {
          pairedIndices.add([i, if (i + 1 < categories.length) i + 1]);
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: pairedIndices.length,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (context, pairIndex) {
            final indices = pairedIndices[pairIndex];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int k = 0; k < indices.length; k++) ...[
                  if (k > 0) SizedBox(height: 10.h),
                  SizedBox(
                    width: 155.w,
                    height: 70.h,
                    child: AnimatedCategoryCard(
                      onTap: (){
                        context.pushNamed(
                          AppRoutes.productCategory,
                          extra: {
                            'categoryId': categories[indices[k]].id,
                            'categoryTitle': categories[indices[k]].name,
                          },
                        );
                      },
                      image: categories[indices[k]].image,
                      title: categories[indices[k]].name,
                      color: assignedColors[pairIndex],
                      delay: indices[k] * 100,
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final productState = ref.watch(productProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.secondary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(productProvider.notifier).refreshProducts();
            await ref.read(videoProvider.notifier).getVideos();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _OrangeHeaderDelegate(topPad: topPad),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF0EB),
                        Color(0xFFFFF0EB),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: ValueListenableBuilder<double>(
                    valueListenable: _scrollProgress,
                    builder: (context, progress, child) {
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: (1.0 - progress).clamp(0.0, 1.0),
                          child: Opacity(
                            opacity: (1.0 - (progress * 2)).clamp(0.0, 1.0),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 10.w,
                        right: 10.w,
                        bottom: 20.h,
                      ),
                      child: SizedBox(
                        height: 150.h,
                        child: _buildHorizontalCategoryGrid(),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, _) {
                    final videoState = ref.watch(videoProvider);

                    if (videoState.isLoading) {
                      return _buildStoryShimmer();
                    }

                    if (videoState.videos.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return SizedBox(
                      height: 190.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        itemCount: videoState.videos.length,
                        separatorBuilder: (_, __) => SizedBox(width: 4.w),
                        itemBuilder: (context, index) {
                          final video = videoState.videos[index];
                          return StoryCard(
                            productModel: video.product!,
                            video: video,
                            allVideos: videoState.videos,
                            initialIndex: index,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(15.w, 20.h, 15.w, 0.h),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "Deal of the Day",
                    style: AppTextStyle.regular(size: 15.sp),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                sliver: SliverToBoxAdapter(child: _buildContent(productState)),
              ),

              SliverPadding(
                padding: EdgeInsets.only(bottom: 80.h, right: 40.w),
                sliver: SliverToBoxAdapter(
                  child: Visibility(
                    visible: productState.products.isNotEmpty,
                    child: Image.asset('assets/madelogo.png'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryShimmer() {
    return SizedBox(
      height: 190.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 90.w,
                    height: 150.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                  Positioned(
                    bottom: -20.h,
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ProductState state) {
    // Error state
    if (state.errorMessage != null && !state.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            const EmptyStateWidget(
              title: 'Failed to load products',
              subtitle: 'Please check your internet connection and try again.',
              icon: Icons.error_outline_rounded,
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => ref.read(productProvider.notifier).retry(),
              child: Text(
                'Retry',
                style: AppTextStyle.bold(color: AppTheme.primary),
              ),
            ),
          ],
        ),
      );
    }

    // Loading state - show shimmer grid
    if (state.isLoading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 0.67,
        ),
        itemBuilder: (_, index) => const ProductShimmerCard(),
      );
    }

    // Empty state
    if (state.products.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: const EmptyStateWidget(),
      );
    }

    // Loaded products

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.products.length + (state.isLoadingMore ? 2 : 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.67,
      ),
      itemBuilder: (_, index) {
        if (index >= state.products.length) {
          return const ProductShimmerCard();
        }

        final product = state.products[index];
        return ProductCard(
          imageUrl: product.images.isNotEmpty ? product.images.first.url : '',
          title: product.title,
          rate: product.price.toString(),
          pcs: product.stock.toString(),
          moq: product.moq.toString(),
          location: product.location ?? '',
          onTap: () {
            context.pushNamed(
              AppRoutes.productDetail,
              extra: {'productId': product.id},
            );
          },
        );
      },
    );
  }
}

class _OrangeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPad;

  const _OrangeHeaderDelegate({required this.topPad});

  @override
  double get maxExtent => topPad + 130;

  @override
  double get minExtent => topPad + 80;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final greetingOpacity = (1.0 - progress * 2.0).clamp(0.0, 1.0);

    final searchBarBottom = 16.0;
    final searchBarTop = maxExtent - shrinkOffset - searchBarBottom - 54;
    final greetingTop = searchBarTop - 6 - 44;

    // ✅ Blur amount: scroll ke saath 0 → 6 tak badhta hai (frosted glass effect)
    final blurAmount = (progress * 6.0).clamp(0.0, 6.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Gradient Background ─────────────────────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.secondary,
                  Color(0xFFFFC5A8),
                  Color(0xFFFFDDD0),
                  Color(0xFFFFF0EB),
                ],
                stops: [0.0, 0.35, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // ── ✅ PRO SHADOW: Gradient painter — hard box-shadow ki jagah ──────
        // Yeh bottom ke baad render hota hai, outside the header clip area.
        // Multi-stop opacity fade = Swiggy / Amazon jaisi professional feel.
        /*Positioned(
          bottom: -28,
          left: 0,
          right: 0,
          height: 28,
          child: IgnorePointer(
            child: CustomPaint(
              painter: _AmbientElevationPainter(opacity: 1.0 - progress * 0.4),
            ),
          ),
        ),*/

        // ── ✅ Scrolled state: ultra-thin bottom border line (iOS style) ────
        // Progress > 0.8 pe subtle 0.5px separator show hota hai
        if (progress > 0.8)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 0.5,
            child: Opacity(
              opacity: ((progress - 0.8) / 0.2).clamp(0.0, 1.0),
              child: Container(color: const Color(0x22000000)),
            ),
          ),

        // ── Greeting ────────────────────────────────────────────────────────
        Positioned(
          top: greetingTop.clamp(topPad + 8, maxExtent).toDouble(),
          left: 16,
          right: 16,
          height: 44,
          child: Opacity(
            opacity: greetingOpacity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hey, ${SharedPrefs().getString(name)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
            ),
          ),
        ),

        // ── Search Bar ──────────────────────────────────────────────────────
        Positioned(
          bottom: searchBarBottom,
          left: 16,
          right: 16,
          height: 50,
          child: const _SearchBar(),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _OrangeHeaderDelegate old) =>
      old.topPad != topPad;
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.pushNamed(AppRoutes.searchScreen);
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Find the perfect lot',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 4),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
