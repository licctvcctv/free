
import 'dart:async';

import 'package:fluwx/fluwx.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_merchant.dart';
import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/toast_util.dart';

class WxLogin{

  static const String appid = 'wxc17e18662283c752';
  static const String universalLink = 'https://freego.freemen.work/';

  static Future<bool> check() async{
    await registerWxApi(appId: appid, doOnAndroid: true, doOnIOS: true, universalLink: universalLink);
    return isWeChatInstalled;
  }

  static Future wxBind({String? mode, required Function(HttpResultObject obj) callback}) async{
    wxCode(success: (code){
      HttpMerchant.bindWechat(code, mode: mode).then((obj){
        callback(obj);
      });
    });
  }

  static Future<bool> wxLogin({required Function(UserModel?) callback}) async{
    return wxCode(success: (code){
      HttpUser.loginByWechat(code).then((user){
        callback(user);
      });
    });
  }

  static Future<bool> wxCode({required Function(String code) success}) async{
    bool isInstalled = await check();
    if(!isInstalled){
      ToastUtil.error('请先安装微信');
      return false;
    }
    String? code;
    StreamSubscription? subscription;
    subscription = weChatResponseEventHandler.listen((BaseWeChatResponse event) async{
      if(event is WeChatAuthResponse){
        if(event.isSuccessful){
          WeChatAuthResponse response = event;
          code = response.code;
          success(code!);
        }
        subscription?.cancel();
      }
    });
    return await sendWeChatAuth(scope: 'snsapi_userinfo', state: 'login');
  }

}
