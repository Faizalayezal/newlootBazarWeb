import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/*class WebViewScreen extends StatefulWidget {

  const WebViewScreen({super.key});

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool? isLoading = true;



  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        allowFileAccessFromFileURLs: true,
        useOnDownloadStart: true,
        javaScriptEnabled: true,
        allowUniversalAccessFromFileURLs: true,
        userAgent: "Mozilla/5.0 (Linux; Android 4.2.2; GT-I9505 Build/JDQ39) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.59 Mobile Safari/537.36",
        javaScriptCanOpenWindowsAutomatically: true,


      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }


  @override
  void dispose() {
    webViewController?.dispose();
    super.dispose();


  }

  Widget mBody() {
      return Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url:WebUri.uri(Uri.parse("https://lootbazaar.inshagroup.in"))),
            initialOptions: options,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var uri = navigationAction.request.url;
              var url = navigationAction.request.url.toString();

              if (Platform.isAndroid && url.contains("intent")) {
                if (url.contains("maps")) {
                  var mNewURL = url.replaceAll("intent://", "https://");
                  if (await canLaunchUrlString(mNewURL)) {
                    await launchUrlString(mNewURL);
                    return NavigationActionPolicy.CANCEL;
                  }
                } else {
                  return NavigationActionPolicy.CANCEL;
                }
              } else if (url.contains("linkedin.com") ||
                  url.contains("market://") ||
                  url.contains("whatsapp://") ||
                  url.contains("truecaller://") ||
                  url.contains("pinterest.com") ||
                  url.contains("snapchat.com") ||
                  url.contains("instagram.com") ||
                  url.contains("play.google.com") ||
                  url.contains("mailto:") ||
                  url.contains("tel:") ||
                  url.contains("share=telegram") ||
                  url.contains("messenger.com")) {
                if (url.contains("https://api.whatsapp.com/send?phone=+")) {
                  url = url.replaceAll("https://api.whatsapp.com/send?phone=+", "https://api.whatsapp.com/send?phone=");
                } else if (url.contains("whatsapp://send/?phone=%20")) {
                  url = url.replaceAll("whatsapp://send/?phone=%20", "whatsapp://send/?phone=");
                }
                if (!url.contains("whatsapp://")) {
                  url = Uri.encodeFull(url);
                }
                try {
                  if (await canLaunchUrlString(url)) {
                    launchUrlString(url);
                  } else {
                    launchUrlString(url);
                  }
                  return NavigationActionPolicy.CANCEL;
                } catch (e) {
                  launchUrlString(url);
                  return NavigationActionPolicy.CANCEL;
                }
              } else if (!["http", "https", "chrome", "data", "javascript", "about"].contains(uri!.scheme)) {
                if (await canLaunchUrlString(url)) {
                  await launchUrlString(
                    url,
                  );
                  return NavigationActionPolicy.CANCEL;
                }
              }
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {
              setState(() {
                isLoading = false;
              });
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          Container(height: MediaQuery.of(context).size.height, color: Colors.white, child: Loader().center().visible(isLoading == true))
        ],
      );

  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return AnnotatedRegion(
      value:  SystemUiOverlayStyle(
        statusBarColor: colorTheme.yellowColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: colorTheme.yellowColor,
            titleSpacing: mq.width*0.00001,
            title: Text(
              'Loot Bazar',
              style: primaryTextStyle(color: colorTheme.backgroundColor,size: 17,weight: FontWeight.w600),
            ),
            leading: GestureDetector(
                onTap: (){
                  context.navigateToScreen(
                      isReplace: 'pop',
                      child:  HomeScreen());
                },
                child: const Icon(Icons.arrow_back, color: Colors.white)),

          ),
          body: mBody(),
        ),
      ),
    );
  }
}*/
