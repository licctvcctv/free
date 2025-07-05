
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';

class WalletHttp{

  WalletHttp._internal();
  static final WalletHttp _instance = WalletHttp._internal();
  factory WalletHttp(){
    return _instance;
  }

  Future<bool> cashWithdraw({required int amount, required String realName, required String bankName, required String bankAccount, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/cash/withdraw';
    bool? result = await HttpTool.post(url, {
      'amount': amount,
      'realName': realName,
      'bankName': bankName,
      'bankAccount': bankAccount
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
