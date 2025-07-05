
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart' hide SimpleUser;
import 'package:freego_flutter/components/friend_neo/friend_common.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/components/friend_neo/user_friend.dart';

class FriendHttp{

  static Future<List<UserFriend>?> getFriends() async{
    const String url = '/user/friend/all';
    List<UserFriend>? list = await HttpTool.get(url, {}, (response){
      List<UserFriend> list = [];
      for(dynamic json in response.data['data']['list']){
        list.add(UserFriend.fromJson(json));
      }
      return list;
    });
    return list;
  }

  static Future<SimpleUser?> searchUserByPhone(String phone) async{
    const String url = '/user/friend/search/phone';
    SimpleUser? user = await HttpTool.get(url, {
      'phone': phone
    }, (response){
      if(response.data['data'] == null){
        return null;
      }
      return SimpleUser.fromJson(response.data['data']);
    });
    return user;
  }

  static Future<List<SimpleUser>?> searchUserByName(String keyword) async{
    const String url = '/user/friend/search/name';
    List<SimpleUser>? list = await HttpTool.get(url, {
      'keyword': keyword
    }, (response){
      List<SimpleUser> list = [];
      for(dynamic json in response.data['data']){
        list.add(SimpleUser.fromJson(json));
      }
      return list;
    });
    return list;
  }

  static Future friendApply(int userId, String backup, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user/friend/apply';
    return HttpTool.post(url, {
      'targetId': userId,
      'description': backup
    }, (response){
      
    }, fail: fail, success: success);
  }

  static Future friendReply(int applyId, UserFriendApplyStatus status, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user/friend/apply';
    return HttpTool.put(url, {
      'applyId': applyId,
      'status': status.getNum()
    }, (response){

    }, fail: fail, success: success);
  }
}
