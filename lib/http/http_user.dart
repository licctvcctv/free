
import "package:dio/dio.dart";
import "package:freego_flutter/http/http_tool.dart" as http_tool;
import "package:freego_flutter/http/http_util.dart";
import "package:freego_flutter/model/user.dart";
import "package:freego_flutter/util/toast_util.dart";
import "http.dart";

class HttpUser{

  static final dio = Dio();
  static const loginUrl = '$URL_BASE_HOST/account/login/password';
  static const phoneCodeUrl = '$URL_BASE_HOST/account/code';
  static const codeLoginUrl = '$URL_BASE_HOST/account/login/code';
  static const userDetailUrl = '$URL_BASE_HOST/user/detail';
  static const basicSaveUrl = '$URL_BASE_HOST/user/saveBasic';
  static const identitySaveUrl = '$URL_BASE_HOST/user/saveIdentity';
  static const invoiceSaveUrl = '$URL_BASE_HOST/user/saveInvoice';
  static const merchantVerifyUrl = '$URL_BASE_HOST/user/saveMerchantVerify';

  static sendCode(String phone,OnDataResponse callback) async {
    final response = await dio.post(phoneCodeUrl, data:{'phone':phone},options: Options(headers: {'contentType': 'application/json'}));
    try {
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      callback(true,null,null,0);
    } catch(e) {
      callback(false,null,e.toString(),0);
    }
  }

  static login(String phone,String password,OnDataResponse callback) async{
    final response = await dio.post(loginUrl, data: {'phone': phone, 'password': password},options: Options(headers: {'contentType': 'application/json'}));
    try {
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      callback(true,response.data['data'],null,0);
    } catch(e) {
      callback(false,null,e.toString(),0);
    }
  }

  static codeLogin(String phone,String code,OnDataResponse callback) async{
    final response = await dio.post(codeLoginUrl, data: {'phone': phone,'code': code},options: Options(headers: {'contentType': 'application/json'}));
    try {
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      callback(true,response.data['data'],null,0);
    } catch(e) {
      callback(false,null,e.toString(),0);
    }
  }

  static loginedUserDetail(OnDataResponse callback) async {
    String? userToken = await UserModel.getUserToken();
    final response = await dio.get(userDetailUrl,options: Options(headers: {'contentType': 'application/json','token':userToken}));
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      // if(response.data[''])
      } catch(e) {
        callback(false,null,e.toString(),0);
        return;
      }
      callback(true,response.data['data'],null,0);
  }

  static saveBasic(Map info,OnDataResponse callback) async{
    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(basicSaveUrl,data: info,options: Options(headers: {'contentType': 'application/json','token':userToken}));
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      // if(response.data[''])
    }
    catch(e) {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

  static saveIdentity(String realName,String identityNum,OnDataResponse callback) async {
    String? userToken = await UserModel.getUserToken();
    final response = await dio.get(identitySaveUrl,
      queryParameters:{'realName':realName,'identityNum':identityNum},
      options: Options(headers: {'contentType': 'application/json','token':userToken})
    );
    try {
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      // if(response.data[''])
    } catch(e) {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

  static saveInvoice(Map info,OnDataResponse callback) async{
    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(invoiceSaveUrl,data: info,options: Options(headers: {'contentType': 'application/json','token':userToken}));
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
    } catch(e) {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

  static saveMerchantVerify(Map info,OnDataResponse callback) async{
    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(merchantVerifyUrl, data: info,options: Options(headers: {'contentType': 'application/json','token':userToken}));
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
    }
    catch(e) {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

  static Future<bool> sendCodeForForgetPassword(String phone, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/account/password/reset';
    Response response = await httpUtil.get(url, data: {
      'phone': phone
    });
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('发送验证码失败');
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

  static Future<UserModel?> passwordResetCodeCheck(String phone, String code, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/account/password/reset/code/check';
    Response response = await httpUtil.get(url, data: {
      'phone': phone,
      'code': code
    });
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('验证失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    UserModel user = UserModel.fromJson(response.data['data']);
    return user;
  }

  static Future<bool> passwordModify(String newPassword, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/account/password/reset/modify';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.put(url, data: {
      'password': newPassword
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('修改密码失败');
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

  static Future<UserModel?> loginByToken({Function(Response)? fail, Function(Response)? success}) async{
    String url = '/account/login/token';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.post(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('登录失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    UserModel user = UserModel.fromJson(response.data['data']);
    return user;
  }

  static Future<UserModel?> loginByWechat(String code, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/account/login/wechat';
    Response response = await httpUtil.post(url, data: {
      'code': code
    });
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('微信登录失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    UserModel user = UserModel.fromJson(response.data['data']);
    return user;
  }

  static Future<UserModel?> loginByApple({required String identityToken, String? userName, String? email, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/account/login/apple';
    UserModel? user = await http_tool.HttpTool.get(url, {
      'token': identityToken,
      'userName': userName,
      'email': email
    }, (response){
      return UserModel.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return user;
  }

  static Future<UserModel?> getUserInfo({Function(Response)? fail, Function(Response)? success}) async{
    String url = '/user';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.get(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取用户信息失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    UserModel user = UserModel.fromJson(response.data['data']);
    return user;
  }
}
