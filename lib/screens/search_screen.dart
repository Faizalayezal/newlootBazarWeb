
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/Products/product_state.dart';
import 'package:lootbazarweb/providerd/Products/search_product_notifier.dart';
import 'package:lootbazarweb/route/app_routes.dart';
import 'package:lootbazarweb/shared/product_card.dart';
import 'package:lootbazarweb/tool/product_shimmer_card.dart';
import 'package:lootbazarweb/shared/empty_state_widget.dart';
import 'package:lootbazarweb/utils/preferences.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final ScrollController _scrollController = ScrollController();
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await SharedPrefs().getSearchHistory();
    setState(() => _history = list);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(searchProductProvider.notifier).loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addToHistory(String query) async {
    if (query.isEmpty) return;
    List<String> newHistory = List.from(_history);
    newHistory.remove(query); // Remove if exists to move to top
    newHistory.insert(0, query);
    if (newHistory.length > 10) newHistory = newHistory.sublist(0, 10);
    setState(() => _history = newHistory);
    await SharedPrefs().saveSearchHistory(newHistory);
  }

  void _removeFromHistory(String query) async {
    List<String> newHistory = List.from(_history);
    newHistory.remove(query);
    setState(() => _history = newHistory);
    await SharedPrefs().saveSearchHistory(newHistory);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final productState = ref.watch(searchProductProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.secondary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _OrangeHeaderSearchDelegate(
                topPad: topPad,
                onSearch: (q) {
                  _addToHistory(q);
                  ref.read(searchProductProvider.notifier).searchNow(q);
                },
              ),
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
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_history.isNotEmpty && productState.products.isEmpty && !productState.isLoading)
                      _buildHistoryList(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: _buildContent(productState),
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

  Widget _buildHistoryList() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              "Recent Searches",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 38.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: _history.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final query = _history[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          ref.read(searchProductProvider.notifier).searchNow(query);
                        },
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          child: Text(
                            query,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _removeFromHistory(query),
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ProductState state) {
    // ── Idle state — kuch search nahi kiya abhi ──
    if (state.searchQuery.isEmpty && state.products.isEmpty && !state.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_rounded, size: 48, color: Colors.grey[300]),
              SizedBox(height: 12.h),
              Text(
                'Find the best deals',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Loading ──
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

    // ── Error ──
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
                'Something went wrong',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () =>
                    ref.read(searchProductProvider.notifier).retry(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ── No results ──
    if (state.products.isEmpty && state.searchQuery.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 80.h),
        child: EmptyStateWidget(
          title: 'No results for "${state.searchQuery}"',
          subtitle: 'Try searching for something else or check your spelling.',
          icon: Icons.search_off_rounded,
        ),
      );
    }

    // ── Products grid ──
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
          imageUrl:
          product.images.isNotEmpty ? product.images.first.url : '',
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

// ─────────────────────────────────────────────────────────────────────────────
// Header Delegate
// ─────────────────────────────────────────────────────────────────────────────
class _OrangeHeaderSearchDelegate extends SliverPersistentHeaderDelegate {
  final double topPad;
  final Function(String) onSearch;
  const _OrangeHeaderSearchDelegate({required this.topPad, required this.onSearch});

  @override
  double get maxExtent => topPad + 130;

  @override
  double get minExtent => topPad + 80;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress =
    (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final greetingOpacity = (1.0 - progress * 2.0).clamp(0.0, 1.0);
    final searchBarBottom = 16.0;
    final searchBarTop =
        maxExtent - shrinkOffset - searchBarBottom - 54;
    final greetingTop = searchBarTop - 6 - 44;

    return Stack(
      clipBehavior: Clip.none,
      children: [
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
        // Back button
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
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  "assets/images/backbtn.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),
            ),
          ),
        ),
        // Title
        Positioned(
          top: greetingTop.clamp(topPad + 8, maxExtent).toDouble(),
          left: 16,
          right: 16,
          height: 44,
          child: Opacity(
            opacity: greetingOpacity,
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                'Search',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2A2A2A),
                ),
              ),
            ),
          ),
        ),
        // Search bar
        Positioned(
          bottom: searchBarBottom,
          left: 16,
          right: 16,
          height: 50,
          child: _SearchBar(onSearch: onSearch),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _OrangeHeaderSearchDelegate old) =>
      old.topPad != topPad;
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar — searchProductProvider use karta hai
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends ConsumerStatefulWidget {
  final Function(String) onSearch;
  const _SearchBar({required this.onSearch});

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
    final productState = ref.watch(searchProductProvider);

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
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true, // ← keyboard turant open ho
              onChanged: (value) {
                ref
                    .read(searchProductProvider.notifier)
                    .onSearchChanged(value);
              },
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  widget.onSearch(value.trim());
                }
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
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              final q = _controller.text.trim();
              if (q.isNotEmpty) {
                widget.onSearch(q);
              } else {
                ref.read(searchProductProvider.notifier).searchNow("");
              }
            },
            child: Container(
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
          ),
        ],
      ),
    );
  }
}
