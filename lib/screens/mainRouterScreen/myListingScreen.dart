import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/Products/ProductState.dart';
import 'package:lootbazarweb/providerd/category/CategoryViseProductNotifier.dart';
import 'package:lootbazarweb/providerd/currantUserListning/CurrentProductNotifier.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/shared/my_listing.dart';
import 'package:lootbazarweb/shared/product_card.dart';
import 'package:lootbazarweb/tool/MyListingShimmer.dart';
import 'package:lootbazarweb/tool/ProductShimmerCard.dart';
import 'package:lootbazarweb/shared/EmptyStateWidget.dart';

class MyListingScreen extends ConsumerStatefulWidget {
  const MyListingScreen({super.key});

  @override
  ConsumerState<MyListingScreen> createState() => _MyListingScreenState();
}

class _MyListingScreenState extends ConsumerState<MyListingScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<double> _scrollProgress = ValueNotifier(0.0);
  static const double _collapseBy = 130.0;

  @override
  void initState() {
    super.initState();
    // Fetch products on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentProductProvider.notifier).getCurrentUserProducts();
    });
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
    final currentProductState = ref.watch(
      currentProductProvider,
    );
    final bool isLoading = currentProductState.isLoading;
    final products =
        currentProductState
            .currantProductResponse
            ?.currantProductData ??
            [];

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
            ref.read(currentProductProvider.notifier).getCurrentUserProducts();

          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _OrangeHeaderSearchDelegate(topPad: topPad,categoryTitle:"My Listing"),
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
                    child: products.isEmpty && !isLoading
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 80.h),
                            child: const EmptyStateWidget(
                              title: 'You haven\'t listed any products yet',
                              subtitle: 'Start selling by creating your first product listing!',
                            ),
                          )
                        : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      itemCount: isLoading
                          ? 5
                          : products.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (isLoading) {
                          return const MyListingShimmer();
                        }
                        final product = products[index];
                        return MyListing(
                          onTap: () {
                            context.pushNamed(
                              AppRoutes.productDetail,
                              extra: {
                                'productId': product.id,
                              },
                            );
                            // navigate to product detail
                          },
                          imageUrl: product.firstImageUrl,
                          title: product.title,
                          rate: product.price.toStringAsFixed(0),
                          pcs: product.stock.toString(),
                          moq: product.moq.toString(),
                          location: product.location ?? '-',
                          status: product.paymentStatus.toLowerCase() == 'pending'
                              ? 'Pending'
                              : product.paymentStatus.toLowerCase() == 'cancel'
                                  ? 'Cancelled'
                                  : product.status,
                        );
                      },
                    ),
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
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed(AppRoutes.sellScreen);
                  }
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

      ],
    );
  }

  @override
  bool shouldRebuild(covariant _OrangeHeaderSearchDelegate old) =>
      old.topPad != topPad;
}
