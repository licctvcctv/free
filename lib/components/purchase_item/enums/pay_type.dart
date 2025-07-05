
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum PayType{
  wechat,
  alipay,
  applepay
}

extension PayTypeExt on PayType{

  String getVal(){
    switch(this){
      case PayType.wechat:
        return 'wechat';
      case PayType.alipay:
        return 'alipay';
      case PayType.applepay:
        return 'applepay';
    }
  }

  static PayType? getPayType(String val){
    for(PayType payType in PayType.values){
      if(payType.getVal() == val){
        return payType;
      }
    }
    return null;
  }

  String getNameCn(){
    switch(this){
      case PayType.wechat:
        return '微信支付';
      case PayType.alipay:
        return '支付宝支付';
      case PayType.applepay:
        return '苹果支付';
    }
  }

  Widget getAssetIcon(){
    switch(this){
      case PayType.wechat:
        return Image.asset('images/pay_weixin.png', fit: BoxFit.fill,);
      case PayType.alipay:
        return Image.asset('images/pay_alipay.png', fit: BoxFit.fill,);
      case PayType.applepay:
        return SvgPicture.asset('svg/apple.svg');
    }
  }
}
