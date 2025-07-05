
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/purchase_item/enums/pay_type.dart';
import 'package:freego_flutter/util/theme_util.dart';

class PayTypeUtil {

  PayTypeUtil._internal();
  static final PayTypeUtil _instance = PayTypeUtil._internal();
  factory PayTypeUtil(){
    return _instance;
  }

  List<PayType> androidPayTypeList = const [PayType.wechat, PayType.alipay];
  List<PayType> applePayTypeList = const [PayType.wechat, PayType.alipay, PayType.applepay];

  Future<PayType?> choosePayType({required BuildContext context}) async{
    List<PayType> availablePayType = const [];
    if(Platform.isIOS){
      availablePayType = applePayTypeList;
    }
    else{
      availablePayType = androidPayTypeList;
    }
    PayType? choosedPayType;
    await showGeneralDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for(int i = 0; i < availablePayType.length; ++i)
                    InkWell(
                      onTap: (){
                        choosedPayType = availablePayType[i];
                        Navigator.of(context).pop();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(i > 0)
                          const Divider(),
                          Row(
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: availablePayType[i].getAssetIcon(),
                              ),
                              const SizedBox(width: 10,),
                              Text(availablePayType[i].getNameCn(), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                              const Expanded(child: SizedBox()),
                              const Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,)
                            ],
                          ),
                        ],
                      )
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
    return choosedPayType;
  }
}
