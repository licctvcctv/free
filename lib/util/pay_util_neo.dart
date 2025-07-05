
import 'dart:convert';

import 'package:fluwx/fluwx.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:tobias/tobias.dart';

class PayUtilNeo{

  PayUtilNeo._internal();
  static final PayUtilNeo _instance = PayUtilNeo._internal();
  factory PayUtilNeo(){
    return _instance;
  }

  Future<bool> alipay(String payInfo) async{
    bool isInstalled = await isAliPayInstalled();
    if(!isInstalled){
      ToastUtil.error('请先安装支付宝');
      return false;
    }
    Map<dynamic, dynamic> payResult = await aliPay(payInfo);
    if(payResult['result'] != null && int.parse(payResult['resultStatus']) == 9000){
      return true;
    }
    if (payResult['resultStatus'] != null) {
      int resultStatus = int.parse(payResult['resultStatus']);
      if (resultStatus == 9000) {
        return true;
      } else if (resultStatus == 6001) {
        ToastUtil.error('支付已取消');
        return false;
      } else {
        ToastUtil.error('支付失败，错误码：$resultStatus');
        return false;
      }
    } else {
      ToastUtil.error('支付失败，未知错误');
      return false;
    }
  }

  final String wechatAppid = 'wxc17e18662283c752';
  final String universalLink = 'https://freego.freemen.work/';
  bool wechatListened = false;
  
  Future<bool> wechatPay(String payInfo, {Function()? onSuccess, Function()? onFail}) async{
    await registerWxApi(appId: wechatAppid, doOnAndroid: true, doOnIOS: true, universalLink: universalLink);
    bool isInstalled = await isWeChatInstalled;
    if(!isInstalled){
      ToastUtil.error('请先安装微信');
      return false;
    }

    Map<String, dynamic> map = json.decoder.convert(payInfo);
    
    weChatResponseEventHandler.listen((BaseWeChatResponse event) {
      if(event is WeChatPaymentResponse){
        if(event.isSuccessful){
          onSuccess?.call();
        }
        else{
          onFail?.call();
        }
      }
    });

    bool result = await payWithWeChat(
      appId: map['appid']!, 
      partnerId: map['partnerid']!, 
      prepayId: map['prepayid']!, 
      packageValue: map['package']!, 
      nonceStr: map['noncestr']!, 
      timeStamp: int.parse(map['timestamp']!), 
      sign: map['sign']!,
    );
    if(!result){
      ToastUtil.error('支付失败');
    }
    return result;
  }
}
