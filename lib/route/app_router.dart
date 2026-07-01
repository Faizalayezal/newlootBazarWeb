import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/providerd/Products/ProductModel.dart';
import 'package:lootbazarweb/providerd/video/VideoListResponse.dart';
import 'package:lootbazarweb/screens/CategoryProductScreen.dart';
import 'package:lootbazarweb/screens/InterestsScreen.dart';
import 'package:lootbazarweb/screens/LoginScreen.dart';
import 'package:lootbazarweb/screens/SearchScreen.dart';
import 'package:lootbazarweb/screens/StoryScreen.dart';
import 'package:lootbazarweb/screens/mainRouterScreen/ProductDetailScreen.dart';
import 'package:lootbazarweb/screens/mainRouterScreen/mainRouterSubScreens/HomeScreen.dart';
import 'package:lootbazarweb/screens/OtpScreen.dart';
import 'package:lootbazarweb/screens/SplashScreen.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/screens/mainRouterScreen/AdaptiveScaffold.dart';
import 'package:lootbazarweb/screens/mainRouterScreen/mainRouterSubScreens/NotificationScreen.dart';
import 'package:lootbazarweb/screens/mainRouterScreen/mainRouterSubScreens/ProfileScreen.dart';
import 'package:lootbazarweb/screens/mainRouterScreen/mainRouterSubScreens/SellScreen.dart';
import 'package:lootbazarweb/screens/mainRouterScreen/mainRouterSubScreens/ShopScreen.dart';
import 'package:lootbazarweb/screens/mainRouterScreen/myListingScreen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: AppRoutes.splashScreen,
      pageBuilder: (context, state) => _page(state, SplashScreen()),
    ),
    GoRoute(
      path: '/login',
      name: AppRoutes.loginScreen,
      pageBuilder: (context, state) => _page(state, const LoginScreen()),
    ),
    GoRoute(
      path: '/otp',
      name: AppRoutes.otpScreen,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        if (data == null) {
          return const LoginScreen();
        }

        return OtpScreen(
          phone: data['phone'],
          countryCode: data['countryCode'],
        );
      },
    ),
    GoRoute(
      path: '/interest',
      name: AppRoutes.interestScreen,
      pageBuilder: (context, state) => _page(state, const InterestsScreen()),
    ),
    GoRoute(
      path: '/setup-profile',
      name: AppRoutes.setupProfileScreen,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        return _page(state, ProfileScreen());
      },
    ),
    GoRoute(
      path: '/product-detail',
      name: AppRoutes.productDetail,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;

        return _page(
          state,
          ProductDetailScreen(
            productId: data?['productId']?.toString() ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: '/product-category',
      name: AppRoutes.productCategory,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return _page(
          state,
          CategoryProductScreen(
            categoryId: data?['categoryId'] ?? '',
            categoryTitle: data?['categoryTitle'] ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: '/storyScreen',
      name: AppRoutes.storyScreen,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return _page(
          state,
          StoryScreen(
            videos: data['videos'] as List<VideoItem>,
            initialIndex: data['initialIndex'] as int,
            productModel: data['productModel'] as VideoProduct,
          ),
        );
      },
    ),
    GoRoute(
      path: '/myListing',
      name: AppRoutes.myListing,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        return _page(state, MyListingScreen());
      },
    ),
    /*ShellRoute(
      builder: (_, __, child) => AuthLayout(child),
      routes: [
        GoRoute(path: '/login', builder: ...),
      ],
    ),*/
    StatefulShellRoute.indexedStack(
      //state save rakhe
      builder: (context, state, navigationShell) {
        return AdaptiveScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: AppRoutes.homeScreen,
              pageBuilder: (context, state) => _page(state, const HomeScreen()),
              routes: [
                GoRoute(
                  path: '/search',
                  name: AppRoutes.searchScreen,
                  parentNavigatorKey: rootNavigatorKey,
                  pageBuilder: (context, state) {
                    /* final title = state.uri.queryParameters['title'] ?? '';
                    final id =
                        int.tryParse(state.uri.queryParameters['id'] ?? '') ??
                            0;
*/
                    return _page(state, SearchScreen());
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shop',
              name: AppRoutes.shopScreen,
              pageBuilder: (context, state) => _page(state, const ShopScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sell',
              name: AppRoutes.sellScreen,
              pageBuilder: (context, state) => _page(state, SellScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notification',
              name: AppRoutes.notificationScreen,
              pageBuilder: (context, state) =>
                  _page(state, const NotificationScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: AppRoutes.profileScreen,
              pageBuilder: (context, state) => _page(state, ProfileScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);

CustomTransitionPage _page(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  );
}
