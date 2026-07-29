import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/Products/product_state.dart';
import 'package:lootbazarweb/providerd/category/category_vise_product_notifier.dart';
import 'package:lootbazarweb/route/app_routes.dart';
import 'package:lootbazarweb/shared/app_text_style.dart';
import 'package:lootbazarweb/shared/product_card.dart';
import 'package:lootbazarweb/tool/product_shimmer_card.dart';
import 'package:lootbazarweb/shared/empty_state_widget.dart';

class CategoryProductScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? categoryTitle;
  const CategoryProductScreen({super.key,this.categoryId,this.categoryTitle});

  @override
  ConsumerState<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends ConsumerState<CategoryProductScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<double> _scrollProgress = ValueNotifier(0.0);
  static const double _collapseBy = 130.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch products on screen load
    Future.microtask(() => ref.read(categoryProductProvider.notifier).getCategoryProducts(categoryIds:widget.categoryId??''));
  }

  void _onScroll() {

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {

      ref.read(categoryProductProvider.notifier).loadMoreCategoryProducts(categoryIds: widget.categoryId);
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
    final productState = ref.watch(categoryProductProvider);

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
            await ref.read(categoryProductProvider.notifier).refreshCategoryProducts(categoryIds: widget.categoryId);
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _OrangeHeaderSearchDelegate(topPad: topPad,categoryTitle:widget.categoryTitle),
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
    // Error state
    if (state.errorMessage != null && !state.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 80.h),
        child: Column(
          children: [
            const EmptyStateWidget(
              title: 'Something went wrong',
              subtitle: 'We couldn\'t fetch the products for this category.',
              icon: Icons.error_outline_rounded,
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => ref.read(categoryProductProvider.notifier).retry(categoryIds: widget.categoryId),
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
        padding: EdgeInsets.symmetric(vertical: 80.h),
        child: const EmptyStateWidget(),
      );
    }

    // Loaded products

    return  GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount:state.products.length +
          (state.isLoadingMore ? 2 : 0),
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
          location: product.location??'',
          onTap: () {
            context.pushNamed(
              AppRoutes.productDetail,
              extra: {
                'productId': product.id,
              },
            );
            // Navigate to product detail with product.id
          },
        );
      },
    );
  }
}

class _OrangeHeaderSearchDelegate extends SliverPersistentHeaderDelegate {
  final double topPad;
  String? categoryTitle;
  _OrangeHeaderSearchDelegate({required this.topPad,this.categoryTitle});

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

        Positioned(
          top: greetingTop.clamp(topPad + 8, maxExtent).toDouble(),
          left: 16,
          right: 16,
          height: 44,
          child: Opacity(
            opacity: greetingOpacity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: (){
                  context.pop();
                },
                child: SvgPicture.asset(
                  "assets/images/backbtn.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),
            ),
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
               categoryTitle??'',
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
    final productState = ref.watch(categoryProductProvider);

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
            color: Colors.black.withValues(alpha: 0.06),
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
                ref.read(categoryProductProvider.notifier).onSearchChanged(value);
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
              ref.read(categoryProductProvider.notifier).searchNow(_controller.text.trim(),);

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