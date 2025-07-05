import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapNavigatorUtil {
  /// 高德地图导航
  static Future<bool> gotoAMap({longitude, latitude,  VoidCallback? toInstallCallBack}) {
    var url =
        '${Platform.isAndroid ? 'android' : 'ios'}amap://navi?sourceApplication=amap&lat=$latitude&lon=$longitude&dev=0&style=2';

    return gotoMap(
        url: url,
        toInstallCallBack: () {
          if (null != toInstallCallBack) {
            toInstallCallBack();
          }
        });
  }

  /// 腾讯地图导航
  static Future<bool> gotoTencentMap(
      {longitude, latitude,  VoidCallback? toInstallCallBack}) async {
    var url =
        'qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&tocoord=$latitude,$longitude&referer=IXHBZ-QIZE4-ZQ6UP-DJYEO-HC2K2-EZBXJ';

    return gotoMap(
        url: url,
        toInstallCallBack: () {
          if (null != toInstallCallBack) {
            toInstallCallBack();
          }
        });
  }

  /// 百度地图导航
  static Future<bool> gotoBaiduMap(
      {longitude, latitude, VoidCallback? toInstallCallBack}) async {
    var url =
        'baidumap://map/direction?destination=$latitude,$longitude&coord_type=gcj02&mode=driving';
    return gotoMap(
        url: url,
        toInstallCallBack: () {
          if (null != toInstallCallBack) {
            toInstallCallBack();
          }
        });
  }

  /// 跳转到第三方地图
  /// [url]跳转地址
  /// [toInstallCallBack]地图未安装回调
  static Future<bool> gotoMap(
      {required String url,  VoidCallback? toInstallCallBack}) async {
    bool canLaunchUrl = await isMapInstall(url);

    print("安装了");
    print(canLaunchUrl);

    if (!canLaunchUrl) {
      if (null != toInstallCallBack) {
        toInstallCallBack();
      }

      //return false;
    }

    await launchUrl(Uri.parse(url));

    return true;
  }

  static void toInstallMap(String url) {
    launchUrl(Uri.parse(url));
  }

  static Future<bool> isBaiduMapInstall() {
    return canLaunchUrl(Uri.parse('baidumap://map/direction'));
  }

  static Future<bool> isTencentMapInstall() {
    return canLaunchUrl(Uri.parse('qqmap://map/routeplan'));
  }

  static Future<bool> isAmapMapInstall() {
    return canLaunchUrl(Uri.parse('${Platform.isAndroid ? 'android' : 'ios'}amap://navi'));
  }

  /// 判断地图是否有安装
  static Future<bool> isMapInstall(String url) {
    return canLaunchUrl(Uri.parse(url));
  }
}
