import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

final ValueNotifier<int> selectedIndexValue = ValueNotifier<int>(0);

class ImageShowIndector extends StatefulWidget {
  ImageShowIndector({super.key, this.images});

  List<String>? images;

  @override
  State<ImageShowIndector> createState() => _ImageShowIndectorState();
}

class _ImageShowIndectorState extends State<ImageShowIndector> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    selectedIndexValue.addListener(() {
      scrollToSecondImage();
      print("Updated changeId 26: ${selectedIndexValue.value}");
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    selectedIndexValue.value = 0;
    super.dispose();
  }

  void scrollToSecondImage() {
    if ((widget.images?.isNotEmpty ?? false) &&
        selectedIndexValue.value < widget.images!.length) {
      _pageController.animateToPage(
        selectedIndexValue.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    /* if ((widget.images?.length ?? 0) > 0) {
      _pageController.animateToPage(
        selectedIndexValue.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 450.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images?.length ?? 0,
                itemBuilder: (context, index) {
                  //   selectedIndexValue.value=index;
                  return Container(
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: CachedNetworkImage(
                      height: 450.h,
                      width: 1.sw,
                      fit: BoxFit.cover,
                      imageUrl:
                          (widget.images != null &&
                              index < widget.images!.length &&
                              widget.images![index].isNotEmpty)
                          ? widget.images![index]
                          : "",
                      placeholder: (context, url) =>
                          Image.asset("assets/images/splashlogo.png"),
                      errorWidget: (context, url, error) =>
                          Image.asset("assets/images/splashlogo.png"),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  //count:  widget.images?.length??0,
                  count: (widget.images?.isNotEmpty ?? false)
                      ? widget.images!.length
                      : 1,
                  effect: ScrollingDotsEffect(
                    activeDotColor: AppTheme.primary,
                    dotColor: Colors.grey,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
