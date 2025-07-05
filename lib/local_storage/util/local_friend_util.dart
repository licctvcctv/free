
import 'package:freego_flutter/components/friend_neo/user_friend.dart';
import 'package:freego_flutter/components/friend_neo/user_friend_api.dart';
import 'package:freego_flutter/local_storage/local_storage_friend.dart';
import 'package:freego_flutter/local_storage/model/local_friend.dart';
import 'package:freego_flutter/local_storage/model/local_user.dart';
import 'package:freego_flutter/local_storage/util/local_user_util.dart';

class LocalFriendUitl{

  LocalFriendUitl._internal();
  static final LocalFriendUitl _instance = LocalFriendUitl._internal();
  factory LocalFriendUitl(){
    return _instance;
  }

  Future<LocalFriendVo?> getVo(int friendId) async{
    return LocalStorageFriend().getVo(friendId);
  }

  Future<List<LocalFriendVo>> listLocal() async{
    return LocalStorageFriend().listAllVo();
  }

  Future<List<LocalFriendVo>> listRefreshed({OnFriendHeadDownload? onFriendHeadDownload}) async{
    List<UserFriend>? friendList = await UserFriendApi().getFriends();
    if(friendList != null){
      List<LocalFriend> localFriends = [];
      for(UserFriend friend in friendList){
        LocalFriend localFriend = LocalFriend.fromUserFriend(friend);
        LocalUser localUser = LocalUser();
        localUser.id = friend.friendId;
        localUser.name = friend.name;
        localUser.headUrl = friend.head;
        localUser.lastUpdateTime = DateTime.now();
        LocalUserUtil().save(localUser, onDownloadHead: (count, total){
          onFriendHeadDownload?.call(localFriend, count, total);
        });
        localFriends.add(localFriend);
      }
      await LocalStorageFriend().replaceTotal(localFriends);
    }
    return listLocal();
  }

  Future<List<LocalFriendVo>> listIfEmpty({OnFriendHeadDownload? onFriendHeadDownload}) async{
    List<LocalFriendVo> localFriends = await listLocal();
    if(localFriends.isEmpty){
      return listRefreshed(onFriendHeadDownload: onFriendHeadDownload);
    }
    else{
      return localFriends;
    }
  }

  Future addFriend(LocalFriend friend) async{
    return LocalStorageFriend().save(friend);
  }

  Future removeFriend(int id) async{
    return LocalStorageFriend().remove(id);
  }
  
}

typedef OnFriendHeadDownload = Function(LocalFriend friend, int count, int total);
