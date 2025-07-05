
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_util.dart';
import 'package:freego_flutter/model/circle.dart';
import 'package:freego_flutter/util/storage.dart';
import 'package:freego_flutter/util/toast_util.dart';

class HttpCircle{

  static Future<Circle?> getCircleById(int id, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/circle/$id';
    Response response = await httpUtil.get(url);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取圈子内容失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    return Circle.fromJson(response.data['data']);
  }

  static Future<CircleActivityExt?> getCircleActivity(int id, {Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/$id';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取圈子内容失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    return CircleActivityExt.fromJson(response.data['data']);
  }

  static Future<bool> applyCircleActivity(int circleId, String description, {Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/activity/apply';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.post(url, data: {
      'circleId': circleId,
      'description': description
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error("申请失败");
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

  static Future<List<CircleActivityApply>?> activityApplyList(int circleId, {Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/activity/apply/all';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {
      'circleId': circleId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取申请列表失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<CircleActivityApply> list = [];
    for(dynamic item in response.data['data']['list']){
      list.add(CircleActivityApply.fromJson(item));
    }
    return list;
  }

  static Future<bool> activityApplyConfirm(int applyId, bool isMakeFriend, String? remarkName, {Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/activity/apply/accept';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.put(url, data: {
      'applyId': applyId,
      'isMakeFriend': isMakeFriend,
      'remarkName': remarkName
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('接收成员失败');
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

  static Future<List<Circle>?> getLatest({Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/latest';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取圈子列表失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<Circle> list = toCircleList(response);
    return list;
  }

  static Future<List<Circle>?> refresh(int maxId, {Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/refresh';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {
      'maxId': maxId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取最新圈子失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<Circle> list = toCircleList(response);
    return list;
  }

  static Future<List<Circle>?> history(int minId, {Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/history';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {
      'minId': minId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取最新圈子失败');
        return null;
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<Circle> list = toCircleList(response);
    return list;
  }

  static List<Circle> toCircleList(Response response){
    List<Circle> list = [];
    for(dynamic json in response.data['data']){
      int? type = json?['circle']?['type'];
      if(type != null){
        switch(type){
          case Circle.TYPE_ACTIVITY:
            list.add(CircleActivityExt.fromJson(json));
            break;
          case Circle.TYPE_ARTICLE:
            list.add(CircleArticle.fromJson(json));
            break;
          case Circle.TYPE_QUESTION:
            list.add(CircleQuestion.fromJson(json));
            break;
          case Circle.TYPE_SHOP:
            list.add(CircleShop.fromJson(json));
            break;
        }
      }
    }
    return list;
  }

  static Future<List<CircleQuestionAnswer>?> questionAnswerLatest(int questionId, {Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/question/answer/latest';
    Response response = await httpUtil.get(url, data: {
      'questionId': questionId
    });
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取回答失败');
        return null;
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<CircleQuestionAnswer> list = toAnswerList(response);
    return list;
  }

  static List<CircleQuestionAnswer> toAnswerList(Response response){
    List<CircleQuestionAnswer> list = [];
    for(dynamic json in response.data['data']){
      list.add(CircleQuestionAnswer.fromJson(json));
    }
    return list;
  }

  static Future<List<Circle>?> myCircleList(int? minId, {Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/my';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {
      'minId': minId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取个人圈子失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<Circle> list = toCircleList(response);
    return list;
  }

  static Future<List<Circle>?> userCircleList(int userId, int? minId, {Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/user/$userId';
    Response response = await httpUtil.get(url, data: {
      'minId': minId
    });
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取用户圈子失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<Circle> list = toCircleList(response);
    return list;
  }

  static Future<bool> createCircleActivity(Circle circle, CircleActivity activity, {Function(Response)? success, Function(Response)? fail}) async{
    String url = '/circle/activity';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.post(url, data: {
      'circle': circle.toJson(),
      'activity': activity.toJson()
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        if(response.data != null && response.data['message'] != null){
          ToastUtil.error(response.data['message']);
        }
        else{
          ToastUtil.error('创建圈子失败');
        }
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
