
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_merchant.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/param_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:tobias/tobias.dart';

class AlipayLogin{
  
  static Future<bool> check() async{
    return await isAliPayInstalled();
  }

  static Future<UserModel?> aliLogin() async{
    String? code = await doAuth();
    if(code == null){
      return null;
    }
    UserModel? user = await HttpMerchant.aliRegiste(code);
    return user;
  }

  static Future<HttpResultObject<UserModel>?> aliBind({String? mode}) async{
    String? code = await doAuth();
    if(code == null){
      return null;
    }
    HttpResultObject<UserModel> result = await HttpMerchant.aliBind(code, mode: mode);
    return result;
  }

  static Future<String?> doAuth() async{
    bool isInstalled = await isAliPayInstalled();
    if(!isInstalled){
      ToastUtil.error('请先安装支付宝');
      return null;
    }
    String? authStr = await HttpMerchant.aliGetAuth();
    if(authStr == null){
      return null;
    }
    Map response = await aliPayAuth(authStr);
    String resultStr = response['result'];
    Map result = ParamUtil.urlParamToMap(resultStr);
    if(response['resultStatus'] != '9000' || result['success'] != 'true' || result['result_code'] != '200'){
      return null;
    }
    return result['auth_code'];
  }

}
