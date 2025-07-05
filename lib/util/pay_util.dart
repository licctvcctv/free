

import 'package:flutter/material.dart';
import 'package:freego_flutter/model/order.dart';
import 'package:freego_flutter/util/ali_pay.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/wx_pay.dart';

class PayUtil {
  static BuildContext? progressContext;

  static showPayDlg(BuildContext context, Order order) async{
    PayType? payType;
    return await showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return StatefulBuilder(builder: (context2, setState) {
          return Center(
            child: Container(
            width: MediaQuery.of(context2).size.width * 0.9,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              borderRadius: BorderRadius.all(Radius.circular(6))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          '订单支付',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black, decoration: TextDecoration.none),
                        )
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(buildContext);
                          },
                          child: const Icon(Icons.close)
                        )
                      )
                    ],
                  )
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '订单号',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black, decoration: TextDecoration.none),
                      ),
                      Text(
                        order.orderSerial!,
                        style: const TextStyle(color: Colors.black54, fontSize: 16, decoration: TextDecoration.none),
                      ),
                    ],
                  )
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '总金额',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black, decoration: TextDecoration.none),
                      ),
                      Text(
                        '￥${(order.totalPrice! / 100).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black54, fontSize: 16, decoration: TextDecoration.none),
                      ),
                    ],
                  )
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: const Text(
                    '请选择付款方式:',
                    style: TextStyle(fontSize: 14, color: Colors.black54, decoration: TextDecoration.none),
                  )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              payType = PayType.wechat;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Row(
                              children: [
                                payType == PayType.wechat ? 
                                const Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.blue,
                                ): 
                                const Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                Image.asset(
                                  'images/pay_weixin.png',
                                  height: 40,
                                  width: 40,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  '微信支付',
                                  style: TextStyle(fontSize: 18, color: Colors.black54, decoration: TextDecoration.none),
                                )
                              ],
                            )
                          ),
                        ),
                        Divider(
                          color: Colors.grey.withOpacity(0.8),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              payType = PayType.alipay;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Row(
                              children: [
                                payType == PayType.alipay ? 
                                const Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.blue,
                                ): 
                                const Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                Image.asset(
                                  'images/pay_alipay.png',
                                  height: 40,
                                  width: 40,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  '支付宝',
                                  style: TextStyle(fontSize: 18, color: Colors.black54, decoration: TextDecoration.none),
                                )
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(43, 142, 233, 1),
                      ),
                      onPressed: () async{
                        if(payType == null){
                          ToastUtil.warn('请选择支付方式');
                          return;
                        }
                        if(payType == PayType.wechat){
                          bool result = await WxPayUtil.pay(order);
                          if(context.mounted){
                            Navigator.of(context).pop(result);
                          }
                        }
                        else if(payType == PayType.alipay){
                          bool result = await AliPayUtil.pay(order);
                          if(context.mounted){
                            Navigator.of(context).pop(result);
                          }
                        }
                      },
                      child: const Text('提交'),
                    )  
                  )
                ],
              ),
            )
          );
        });
      }
    );
  }
}
