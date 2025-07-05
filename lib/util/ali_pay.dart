
import 'package:freego_flutter/http/http_order.dart';
import 'package:freego_flutter/model/order.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:tobias/tobias.dart';

class AliPayUtil{

  static Future<bool> pay(Order order) async{
    bool isInstalled = await isAliPayInstalled();
    if(!isInstalled){
      ToastUtil.error('请先安装支付宝');
      return false;
    }
    String? payInfo = await HttpOrder.alipayPrepay(order.id);
    if(payInfo == null){
      ToastUtil.error('预下单失败');
      return false;
    }
    Map<dynamic, dynamic> payResult = await aliPay(payInfo);
    if(payResult['result'] != null && int.parse(payResult['resultStatus']) == 9000){
      ToastUtil.hint('支付成功');
      return true;
    }
    ToastUtil.error('支付失败');
    return false;
  }
}
