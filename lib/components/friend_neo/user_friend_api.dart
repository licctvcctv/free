
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/components/friend_neo/user_friend.dart';

class UserFriendApi{

  UserFriendApi._internal();
  static final UserFriendApi _instance = UserFriendApi._internal();
  factory UserFriendApi(){
    return _instance;
  }

  Future<List<UserFriend>?> getFriends() async{
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

  Future<bool> removeFriend(int friendId) async{
    const String url = '/user/friend';
    bool? result = await HttpTool.delete(url, {
      'friendId': friendId
    }, (response){
      return true;
    });
    return result ?? false;
  }
  
}
