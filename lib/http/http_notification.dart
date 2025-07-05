

import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_util.dart';
import 'package:freego_flutter/model/notification.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/toast_util.dart';

class HttpNotification{

  static Future<List<NotificationModel>?> list(NotificationType type, {int? pageNum, int? pageSize, int? maxId, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/notification/list';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.get(url, data: {
      'type': type.getNum(),
      'pageNum': pageNum,
      'pageSize': pageSize,
      'maxId': maxId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取通知失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<NotificationModel> list = [];
    for(dynamic item in response.data['data']){
      NotificationModel notification = NotificationModel.fromJson(item);
      list.add(notification);
    }
    return list;
  }

}
