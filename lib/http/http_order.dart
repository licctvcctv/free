
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_util.dart';
import 'package:freego_flutter/model/order.dart';
import 'package:freego_flutter/model/order_customer.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/storage.dart';
import 'package:freego_flutter/util/toast_util.dart';

class HttpOrder{

  static Future<List<Order>?> getLatest(int? endId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/order/latest';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {
      'endId': endId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取订单失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<Order> list = [];
    for(dynamic item in response.data['data']){
      list.add(Order.fromJson(item));
    }
    return list;
  }
  
  static Future<List<OrderCustomer>?> getCustomer(int orderId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/order/customer';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {
      'orderId': orderId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取个人信息失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<OrderCustomer> list = [];
    for(dynamic item in response.data['data']){
      list.add(OrderCustomer.fromJson(item));
    }
    return list;
  }

  static Future<String?> wechatPrepay(int orderId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/order/pay/wechat';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {
      'orderId': orderId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('微信下单失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    return response.data['data'];
  }

  static Future<String?> alipayPrepay(int orderId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/order/pay/alipay';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.get(url, data: {
      'orderId': orderId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('支付宝下单失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    return response.data['data'];
  }

  static Future<Order?> getOrderDetail(int orderId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/order/$orderId';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.get(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取订单详情失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    Order order = Order.fromJson(response.data['data']);
    return order;
  }
}
