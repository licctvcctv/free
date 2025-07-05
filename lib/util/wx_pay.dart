
import 'dart:async';
import 'dart:convert';

import 'package:fluwx/fluwx.dart';
import 'package:freego_flutter/http/http_order.dart';
import 'package:freego_flutter/model/order.dart';
import 'package:freego_flutter/util/toast_util.dart';

class WxPayUtil{

  static const String appid = 'wxc17e18662283c752';
  static const String universalLink = 'https://freego.freemen.work/';

  static Future<bool> check() async{
    await registerWxApi(appId: appid, doOnAndroid: true, doOnIOS: true, universalLink: universalLink);
    return isWeChatInstalled;
  }

  static Future<bool> pay(Order order) async{
    bool isInstalled = await check();
    if(!isInstalled){
      ToastUtil.error('请先安装微信');
      return false;
    }
    String? payInfo = await HttpOrder.wechatPrepay(order.id);
    if(payInfo == null){
      return false;
    }
    Map<String, dynamic> map = json.decoder.convert(payInfo);
    StreamSubscription? subscription;
    subscription = weChatResponseEventHandler.listen((BaseWeChatResponse event) {
      if(event is WeChatPaymentResponse){
        if(event.isSuccessful){
          ToastUtil.hint('微信支付成功');
        }
        else{
          ToastUtil.error('微信支付失败');
        }
        subscription?.cancel();
      }
    });

    //payWithWeChat(appId: appId, partnerId: partnerId, prepayId: prepayId, packageValue: packageValue, nonceStr: nonceStr, timeStamp: timeStamp, sign: sign);
    return payWithWeChat(
      appId: map['appid']!, 
      partnerId: map['partnerid']!, 
      prepayId: map['prepayid']!, 
      packageValue: map['package']!, 
      nonceStr: map['noncestr']!, 
      timeStamp: int.parse(map['timestamp']!), 
      sign: map['sign']!);
    
  }

}
