
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/util/theme_util.dart';

class PayTypeChooseUtil{

  PayTypeChooseUtil._internal();
  static final PayTypeChooseUtil _instance = PayTypeChooseUtil._internal();
  factory PayTypeChooseUtil(){
    return _instance;
  }

  Future<PayType?> choose(BuildContext context) async{
    dynamic result = await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Material(
              color: Colors.transparent,
              child: PayTypeChooseWidget(),
            )
          ],
        );
      },
    );
    if(result is PayType){
      return result;
    }
    return null;
  }
}

class PayTypeChooseWidget extends StatefulWidget{
  const PayTypeChooseWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return PayTypeChooseState();
  }
  
}

class PayTypeChooseState extends State<PayTypeChooseWidget>{

  PayType? payType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('支付方式', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 10,),
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
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: (){
                  Navigator.of(context).pop(payType);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    border: Border.fromBorderSide(BorderSide(color: ThemeUtil.buttonColor))
                  ),
                  child: const Text('O K', style: TextStyle(color: ThemeUtil.buttonColor),),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

}