import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/route/app_router.dart';
import 'package:lootbazarweb/tool/NotSupportedScreen.dart';
import 'package:lootbazarweb/url_strategy/url_strategy_stub.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/services.dart';
import 'constant/AppToast.dart';
import 'utils/preferences.dart';


void main() async  {
  configureUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  AppToast.navigatorKey = rootNavigatorKey;

  await SharedPrefs().init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {


        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
          builder: (context, child) {
            final width = MediaQuery.of(context).size.width;
            if (width > 700) {
              return const NotSupportedScreen();
            }

            return ResponsiveBreakpoints.builder(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              ),
              breakpoints: const [
                Breakpoint(start: 0, end: 700, name: MOBILE),
                Breakpoint(start: 701, end: 1100, name: TABLET),
                Breakpoint(start: 1101, end: 1920, name: DESKTOP),
              ],
            );
          },
        );
      },
    );
  }
}