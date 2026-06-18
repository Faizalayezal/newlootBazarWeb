import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lootbazarweb/providerd/category/CategoryNotifier.dart';
import 'package:lootbazarweb/providerd/register/RegisterNotifier.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';

/*class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  late AnimationController controller;

  final int pieces = 16;

  final Random random = Random();

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    controller.forward();

    Future.delayed(const Duration(seconds: 6), () {
      context.goNamed(AppRoutes.loginScreen);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildPiece(int index) {

    final row = index ~/ 4;
    final col = index % 4;

    final randomX = random.nextDouble() * 300 - 150;
    final randomY = random.nextDouble() * 300 - 150;

    final rotation = random.nextDouble() * pi * 2;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {

        double progress = controller.value;

        double explode =
        sin(progress * pi);

        return Transform.translate(
          offset: Offset(
            randomX * explode,
            randomY * explode,
          ),
          child: Transform.rotate(
            angle: rotation * explode,
            child: Transform.scale(
              scale: 1 - (explode * 0.3),
              child: Opacity(
                opacity: 1 - (explode * 0.2),
                child: child,
              ),
            ),
          ),
        );
      },
      child: ClipRect(
        child: Align(
          alignment: Alignment(
            -1 + (col * 0.66),
            -1 + (row * 0.66),
          ),
          widthFactor: 0.25,
          heightFactor: 0.25,
          child: Image.asset(
            "assets/logo.png",
            width: 300,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [

            // glow effect
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.15),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            )
                .animate(
              onPlay: (c) => c.repeat(reverse: true),
            )
                .scale(
              duration: 2.seconds,
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
            ),

            SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                children: List.generate(
                  pieces,
                      (index) => buildPiece(index),
                ),
              ),
            ),

            // center flash
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            )
                .animate()
                .scale(
              duration: 1200.ms,
              begin: const Offset(0, 0),
              end: const Offset(15, 15),
              curve: Curves.easeOutExpo,
            )
                .fadeOut(),
          ],
        ),
      ),
    );
  }
}*/


class SplashScreen extends ConsumerStatefulWidget {
  static String tag = '/SplashScreen';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create position animation (down to up)
    _animation = Tween<double>(
      begin: -0.5, // Start from bottom (outside screen)
      end: 0.0, // End at center
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    // Create opacity animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint("PostFrame");

      await _init();

      debugPrint("Init Completed");
    });
  }


  Future<void> _init() async {
    debugPrint("Start");

    await Future.delayed(const Duration(seconds: 3));

    debugPrint("Before API");

    await ref.read(categoryProvider.notifier).fetchAndCacheCategories();

    debugPrint("After API");

    if (!mounted) return;

    final isUserLoggedIn =
    await ref.read(registerProvider.notifier).getUserData();

    if (!mounted) return;

    if (isUserLoggedIn) {
      context.goNamed(AppRoutes.homeScreen);
    } else {
      //context.goNamed(AppRoutes.interestScreen);
      context.goNamed(AppRoutes.loginScreen);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive logo size
    final logoSize = min(screenWidth, screenHeight) * 0.5;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                _animation.value * screenHeight,
              ),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: logoSize,
                        height: logoSize,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: SvgPicture.asset(
                            'assets/logo.svg',
                            width: 75.w,
                            height: 75.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}









































  /*@override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 220,
          width: 220,
          child: RiveAnimation.asset(
            'assets/logo.rpngiv',
          ),
        ),
      ),
    );
  }
}*/