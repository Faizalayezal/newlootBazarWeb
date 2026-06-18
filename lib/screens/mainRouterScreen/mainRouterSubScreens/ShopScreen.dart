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
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/shared/product_card.dart';
import 'package:lootbazarweb/tool/ProductShimmerCard.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<double> _scrollProgress = ValueNotifier(0.0);
  static const double _collapseBy = 130.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch products on screen load
    Future.microtask(() => ref.read(productProvider.notifier).getProducts());
  }

  void _onScroll() {
    final offset = _scrollController.offset.clamp(0.0, _collapseBy);
    _scrollProgress.value = offset / _collapseBy;
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse &&
        _scrollController.offset > 100) {
      NavBarController.showNavBar.value = false;
    } else if (direction == ScrollDirection.forward) {
      NavBarController.showNavBar.value = true;
    }
    //----------------------------
    // Pagination
    //----------------------------

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {

      ref.read(productProvider.notifier).loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollProgress.dispose();
    super.dispose();
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
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(productProvider.notifier).refreshProducts();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _OrangeHeaderSearchDelegate(topPad: topPad),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF0EB),
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: _buildContent(productState),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ProductState state) {
    debugPrint('🔍 BUILD: loading=${state.isLoading} | products=${state.products.length} | error=${state.errorMessage}');
    // Error state
    // ── Loading (initial) ──────────────────────────────────────────────────────
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
        itemBuilder: (_, __) => const ProductShimmerCard(),
      );
    }

    // ── Error (only when products list is also empty) ──────────────────────────
    // If products already loaded once, don't wipe them — show them + snackbar
    if (state.errorMessage != null && state.products.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 100.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey[400]),
              SizedBox(height: 12.h),
              Text(
                'Failed to load products',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => ref.read(productProvider.notifier).retry(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Empty state ────────────────────────────────────────────────────────────
    if (state.products.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 100.h),
        child: Center(
          child: Text(
            'No products found',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ),
      );
    }

    // ── Products grid ──────────────────────────────────────────────────────────
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
              extra: {
                'productId': product.id,
              },
            );
          },
        );
      },
    );
  }
}

class _OrangeHeaderSearchDelegate extends SliverPersistentHeaderDelegate {
  final double topPad;
  const _OrangeHeaderSearchDelegate({required this.topPad});

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
              alignment: Alignment.center,
              child: Text(
                'Products',
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
  bool shouldRebuild(covariant _OrangeHeaderSearchDelegate old) =>
      old.topPad != topPad;
}

class _SearchBar extends ConsumerStatefulWidget  {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final TextEditingController _controller = TextEditingController();


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    // Provider -> Controller Sync
    if (_controller.text != productState.searchQuery) {
      _controller.value = TextEditingValue(
        text: productState.searchQuery,
        selection: TextSelection.collapsed(
          offset: productState.searchQuery.length,
        ),
      );
    }
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        // ✅ Fully pill shaped — screenshot mein ekdum round hai dono sides
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            // ✅ Very subtle shadow — barely visible in screenshot
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ Grey search icon — LEFT side (screenshot mein clearly hai)
          SizedBox(width: 16.w),
          Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
          SizedBox(width: 10.w),

          // Hint text
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                ref.read(productProvider.notifier).onSearchChanged(value);
              },
              decoration: InputDecoration(
                hintText: 'Find the perfect lot',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // ✅ Orange circle button — RIGHT side, tight to edge
          // Screenshot mein yeh solid orange circle hai, no gradient
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus(); // dismiss keyboard
              // force immediate search bypassing debounce
              ref.read(productProvider.notifier).searchNow(_controller.text.trim());

            },
            child: Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 4),
              decoration: const BoxDecoration(
                color: AppTheme.primary, // exact orange from screenshot
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

