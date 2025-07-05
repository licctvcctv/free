
import 'dart:io';

import 'package:freego_flutter/util/toast_util.dart';
import 'package:url_launcher/url_launcher.dart';

class AppRedirect{

  static Future<bool> gotoGaodeMap(double lat, double lng, {String? address}) async{
    String? url;
    if(Platform.isAndroid){
      url = 'amapuri://route/plan/?sid=&slat=&slon=&sname=&did=&dlat=$lat&dlon=$lng&dname=${address ?? ''}&dev=0&t=0';
    }
    else if(Platform.isIOS){
      url = 'iosamap://route/plan/?sid=&slat=&slon=&sname=&did=&dlat=$lat&dlon=$lng&dname=${address ?? ''}&dev=0&t=0';
    }
    else{
      return false;
    }
    Uri uri = Uri.parse(url);
    if(! await canLaunchUrl(uri)){
      ToastUtil.error('未检测到高德地图');
      return false;
    }
    await launchUrl(uri);
    return true;
  }
}
