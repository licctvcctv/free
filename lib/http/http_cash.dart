
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_util.dart';
import 'package:freego_flutter/model/cash.dart';
import 'package:freego_flutter/model/customer.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class HttpCash{

  static Future<Cash?> getCash({Function(Response)? fail, Function(Response)? success}) async{
    String url = '/cash';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.get(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('查询余额失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    Cash cash = Cash.fromJson(response.data['data']);
    return cash;
  }

  static Future<Customer?> getCustomer({Function(Response)? fail, Function(Response)? success}) async{
    String url = '/cash/customer';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.get(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('查询商户信息失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    Customer customer = Customer.fromJson(response.data['data']);
    return customer;
  }

  static Future<List<CashLog>?> getCashLog({int? maxId, int? pageNum, int? pageSize, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/cash/log/latest';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.get(url, data: {
      'maxId': maxId,
      'pageNum': pageNum,
      'pageSize': pageSize
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('查询流水信息失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<CashLog> list = [];
    for(dynamic item in response.data['data']){
      list.add(CashLog.fromJson(item));
    }
    return list;
  }

  static Future<List<CashLog>?> getCashLogByDateRange(DateTime startDate, DateTime endDate, {int? pageNum, int? pageSize, Function(Response)? fail, Function(Response)? success }) async{
    String url = '/cash/log/date';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.get(url, data: {
      'startDate': DateTimeUtil.toYMD(startDate),
      'endDate': DateTimeUtil.toYMD(endDate),
      'pageNum': pageNum,
      'pageSize': pageSize
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('查询流水列表失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<CashLog> list = [];
    for(dynamic item in response.data['data']){
      list.add(CashLog.fromJson(item));
    }
    return list;
  }
  
  static Future<CashWithdraw?> getCashWithdraw(int id, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/cash/withdraw/$id';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.get(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('查询提现信息失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    CashWithdraw withdraw = CashWithdraw.fromJson(response.data['data']);
    return withdraw;
  }
  
  static Future<bool> modifyCustomer({String? realName, String? bankName, String? bankAccount, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/cash/customer';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.put(url, data: {
      'realName': realName,
      'bankName': bankName,
      'bankAccount': bankAccount
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('修改钱包信息失败');
      }
      else{
        fail(response);
      }
      return false;
    }
    if(success != null){
      success(response);
    }
    return true;
  }
}
