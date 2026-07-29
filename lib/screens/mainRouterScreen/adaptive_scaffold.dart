import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/bottomNav/custom_bottom_nav_bar.dart';
import 'package:lootbazarweb/bottomNav/custom_rail_nav.dart';
import 'package:lootbazarweb/bottomNav/nav_bar_controller.dart';
import 'package:lootbazarweb/providerd/Products/product_notifier.dart';

class AdaptiveScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveScaffold({super.key, required this.navigationShell});

  static const _rootRoutes = [
    '/home',
    '/shop',
    '/sell',
    '/notification',
    '/profile',
  ];

  bool _useRail(BoxConstraints constraints) => constraints.maxWidth >= 600;

  void _handlePop(BuildContext context, bool didPop) {
    if (didPop) return;
    final location = GoRouterState.of(context).uri.toString();
    final router = GoRouter.of(context);
    if (!_rootRoutes.contains(location)) {
      router.pop();
      return;
    }
    if (location != '/home') {
      navigationShell.goBranch(0);
      return;
    }
    if (kIsWeb) {
      if (router.canPop()) router.pop();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = _useRail(constraints);
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) => _handlePop(context, didPop),
          child: SafeArea(
            maintainBottomViewPadding: true,
            top: false,
            child: Scaffold(
              extendBody: true,
              body: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: useRail
                        ? CustomRailNav(
                            key: const ValueKey('rail'),
                            selectedIndex: navigationShell.currentIndex,
                            onDestinationSelected: navigationShell.goBranch,
                          )
                        : const SizedBox.shrink(key: ValueKey('no-rail')),
                  ),
                  Expanded(child: navigationShell),
                ],
              ),
              bottomNavigationBar: ValueListenableBuilder<bool>(
                      valueListenable: NavBarController.showNavBar,
                      builder: (context, visible, child) {
                        return AnimatedSlide(
                          offset: visible ? Offset.zero : const Offset(0, 1.2),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          child: child!,
                        );
                      },
                      child: CustomBottomNavBar(
                        selectedIndex: navigationShell.currentIndex,
                        onTap: (index) async {
                          navigationShell.goBranch(index);

                          if (index == navigationShell.currentIndex) {
                            return;
                          }

                          if (navigationShell.currentIndex == 1) {
                            await ref.read(productProvider.notifier).resetSearch();
                          }
                        },
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

/*class AdaptiveScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveScaffold({super.key, required this.navigationShell});

  bool _useRail(BoxConstraints constraints) {
    return constraints.maxWidth >= 600;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = _useRail(constraints);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            // Check if we're on a nested route within a branch
            final location = GoRouterState.of(context).uri.toString();
            final router = GoRouter.of(context);

            // If on /home/add or any nested route, go back to branch root
            if (location != '/home' &&
                location != '/shop' &&
                location != '/sell' &&
                location != '/notification' &&
                location != '/profile') {
              router.pop();
              return;
            }

            // If on Settings, go back to Home
            if (location.startsWith('/shop')) {
              navigationShell.goBranch(0); // Go to Home branch
              return;
            }

            // If on Home root, exit app
            if (kIsWeb) {
              // Do nothing on web
              if (router.canPop()) {
                router.pop();
              }
            } else {
              SystemNavigator.pop();
            }
          },
          child: SafeArea(
            maintainBottomViewPadding: true,
            top: false,
            child: Scaffold(
              body: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: useRail
                        ? NavigationRail(
                            key: const ValueKey('rail'),
                            selectedIndex: navigationShell.currentIndex,
                            onDestinationSelected: navigationShell.goBranch,
                            destinations: [
                              NavigationRailDestination(
                                icon: HoverIcon(
                                  icon: Icons.home_outlined,
                                  selectedIcon: Icons.home,
                                  selected: navigationShell.currentIndex == 0,
                                ),
                                label: Text('Home'),
                              ),
                              NavigationRailDestination(
                                icon: HoverIcon(
                                  icon: Icons.settings_outlined,
                                  selectedIcon: Icons.settings,
                                  selected: navigationShell.currentIndex == 1,
                                ),
                                label: Text('Settings'),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(key: ValueKey('no-rail')),
                  ),
                  Expanded(child: navigationShell),
                ],
              ),

              bottomNavigationBar: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: useRail
                    ? const SizedBox.shrink(key: ValueKey('no-bottom'))
                    : NavigationBar(
                        key: const ValueKey('bottom'),
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: navigationShell.goBranch,
                        destinations: const [
                          NavigationDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home),
                            label: 'Home',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.settings_outlined),
                            selectedIcon: Icon(Icons.settings),
                            label: 'Settings',
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}*/
