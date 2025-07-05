
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/purchase_item/model/user_credit.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_tool.dart';

class UserCreditApi{

  UserCreditApi._internal();
  static final UserCreditApi _instance = UserCreditApi._internal();
  factory UserCreditApi(){
    return _instance;
  }

  Future<UserCredit?> getCredit({Function(Response)? success, Function(Response)? fail}) async{
    const url = URL_BASE_HOST + '/user_credit';
    UserCredit? credit = await HttpTool.get(url, {
    }, (response){
      return UserCredit.fromJson(response.data['data']);
    });
    return credit;
  }
}
