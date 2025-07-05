
import 'dart:async';
import 'dart:io';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freego_flutter/components/intro/intro.dart';
import 'package:freego_flutter/components/merchent/merchant_identify.dart';
import 'package:freego_flutter/components/user/login.dart';
import 'package:freego_flutter/components/user/user_center.dart';
import 'package:freego_flutter/components/user/user_edit.dart';
import 'package:freego_flutter/components/user/user_identity_edit.dart';
import 'package:freego_flutter/components/user/user_invoice_edit.dart';
import 'package:freego_flutter/components/user/user_set.dart';
import 'package:freego_flutter/components/view/common_amap.dart';
import 'package:freego_flutter/config/const_config.dart';
import 'package:freego_flutter/util/context_util.dart';
import 'package:freego_flutter/util/iap_util.dart';
import 'package:freego_flutter/util/route_observer.dart';
import 'package:uni_links/uni_links.dart';

import 'components/video/video_home.dart';
import 'components/video/video_model.dart';
void main() {

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  if(Platform.isAndroid){
    TextInputBinding();
  }
    // 初始化微信SDK
  fluwx.registerWxApi(
    appId: 'wxc17e18662283c752',
    universalLink: 'https://freego.freemen.work/',
  );

  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'freego',
        debugShowCheckedModeBanner: false,
        supportedLocales: const [
          //此处 系统是什么语言就显示什么语言
          Locale('zh', 'CH'),
          Locale('en', 'US'),
        ],
        navigatorObservers: [RouteObserverUtil.instance.routeObserver],
        routes: {
          '/user/center': (ctx) => const UserCenterPage(),
          '/user/set': (ctx) => const UserSetPage(),
          '/user/edit':(ctx) => const UserEditPage(),
          '/user/identity':(ctx) => const UserIdentityEditPage(),
          '/user/invoice':(ctx) => const UserInvoiceEditPage(),
          '/merchant/identify':(ctx) => const MerchantIdentifyPage(),
          '/login': (context) => const LoginPage(),
          '/common/amap': (context) => const CommonAmapPage(),
        },
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        home: const IntroPage(),
        navigatorKey: navigatorKey,
        builder: ((context, child) {
          AMapFlutterLocation.setApiKey(ConstConfig.amapLocationKeyOfAndroid, ConstConfig.amapLocationKeyOfIOS);
          AMapFlutterLocation.updatePrivacyShow(true, true);
          AMapFlutterLocation.updatePrivacyAgree(true);
          ContextUtil.init(navigatorKey);
          IapUtil();
          return FToastBuilder()(context, child);
        }),
        onGenerateRoute: (settings) {
          // 处理深度链接路由
          if (settings.name != null && settings.name!.startsWith('/video/')) {
            final videoId = settings.name!.split('/').last;
            return MaterialPageRoute(
              builder: (context) => VideoHomePage(
                initVideo: VideoModel()..id = int.tryParse(videoId),
              ),
            );
          }
          return null;
        },
      )
    ),
  );
  _initDeepLinks();
}

void _initDeepLinks() async {
  try {
    // 处理冷启动链接
    Uri? initialUri = await getInitialUri();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // 监听热启动链接
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      debugPrint('Deep link error: $err');
    });
  } catch (e) {
    debugPrint('Deep link init error: $e');
  }
}

void _handleDeepLink(Uri uri) {
  debugPrint('Received deep link: $uri');
  
  // 示例: https://freego.freemen.work/video/123
  if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'video') {
    String videoId = uri.pathSegments[1];
    // 导航到视频详情页
    if (ContextUtil.getContext() != null) {
      Navigator.of(ContextUtil.getContext()!).push(
        MaterialPageRoute(
          builder: (context) => VideoHomePage(
            //initVideo: VideoModel(id: int.tryParse(videoId)),
            initVideo: VideoModel()..id = int.tryParse(videoId),
          ),
        ),
      );
    }
  }
}
