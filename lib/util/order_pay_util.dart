
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/order_neo/api/order_pay_api.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:tobias/tobias.dart';

class OrderPayUtil{

  OrderPayUtil._internal();
  static final OrderPayUtil _instance = OrderPayUtil._internal();
  factory OrderPayUtil(){
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
    ToastUtil.error('支付失败');
    return false;
  }

  final String wechatAppid = 'wxc17e18662283c752';
  final String universalLink = 'https://service.freego.freemen.work/';
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
  
  Future showPayDialog(BuildContext context, String orderSerial){
    PayType? payType;
    return showGeneralDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder:(context, animation, secondaryAnimation) {
        return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) { 
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                child: Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('订单支付', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          const Text('订单号：', style: TextStyle(color: ThemeUtil.foregroundColor),),
                          Expanded(
                            child: Text(orderSerial),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: (){
                          payType = PayType.alipay;
                          setState((){});
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'images/pay_alipay.png',
                              height: 40,
                              width: 40,
                            ),
                            const SizedBox(width: 10,),
                            const Text('支付宝支付', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            payType == PayType.alipay ? 
                            const Icon(
                              Icons.radio_button_checked,
                              color: Colors.blue,
                            ): 
                            const Icon(
                              Icons.radio_button_unchecked,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      InkWell(
                        onTap: (){
                          payType = PayType.wechat;
                          setState((){});
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'images/pay_weixin.png',
                              height: 40,
                              width: 40,
                            ),
                            const SizedBox(width: 10,),
                            const Text("微信支付", style: TextStyle(color: ThemeUtil.foregroundColor),),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            payType == PayType.wechat ? 
                            const Icon(
                              Icons.radio_button_checked,
                              color: Colors.blue,
                            ): 
                            const Icon(
                              Icons.radio_button_unchecked,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue
                            ),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: const Text('取消'),
                          ),
                          const SizedBox(width: 24,),
                          ElevatedButton(
                            onPressed: () async{
                              if(payType == null){
                                ToastUtil.warn('请选择支付方式');
                                return;
                              }
                              if(payType == PayType.alipay){
                                String? payInfo = await OrderPayApi().payByAlipay(orderSerial: orderSerial);
                                if(payInfo == null){
                                  ToastUtil.error('预支付失败');
                                  return;
                                }
                                bool result = await alipay(payInfo);
                                if(context.mounted){
                                  Navigator.of(context).pop(result);
                                }
                              }
                              else if(payType == PayType.wechat){
                                String? payInfo = await OrderPayApi().payByWechat(orderSerial: orderSerial);
                                if(payInfo == null){
                                  ToastUtil.error('预支付失败');
                                  return;
                                }
                                bool result = await wechatPay(payInfo);
                                if(context.mounted){
                                  Navigator.of(context).pop(result);
                                }
                              }
                            }, 
                            child: const Text('确认')
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },);
      },
    );
  }
}
