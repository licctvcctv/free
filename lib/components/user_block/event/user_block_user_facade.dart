import 'package:dio/dio.dart';
import 'package:freego_flutter/components/user_block/api/user_block_user_api.dart';

class UserBlockUserFacade{

  List<AfterBlockedUserHandler> _blockedHandlerList = [];
  List<AfterUnblockedUserHandler> _unblockedHandlerList = [];

  UserBlockUserFacade._internal();
  static final UserBlockUserFacade _instance = UserBlockUserFacade._internal();
  factory UserBlockUserFacade(){
    return _instance;
  }

  bool addBlockedHandler(AfterBlockedUserHandler handler){
    if(_blockedHandlerList.contains(handler)){
      return false;
    }
    List<AfterBlockedUserHandler> tmpList = [];
    tmpList.addAll(_blockedHandlerList);
    tmpList.add(handler);
    _blockedHandlerList = tmpList;
    return true;
  }

  bool removeBlockedHandler(AfterBlockedUserHandler handler){
    return _blockedHandlerList.remove(handler);
  }

  bool addUnblockedHandler(AfterUnblockedUserHandler handler){
    if(_unblockedHandlerList.contains(handler)){
      return false;
    }
    List<AfterUnblockedUserHandler> tmpList = [];
    tmpList.addAll(_unblockedHandlerList);
    tmpList.add(handler);
    _unblockedHandlerList = tmpList;
    return true;
  }

  bool removeUnblockedHandler(AfterUnblockedUserHandler handler){
    return _unblockedHandlerList.remove(handler);
  }

  Future<bool> block({required int userId, Function(Response)? success, Function(Response)? fail}) async{
    bool result = await UserBlockUserApi().block(blockId: userId, success: success, fail: fail);
    if(result){
      for(AfterBlockedUserHandler handler in _blockedHandlerList){
        handler.handle();
      }
    }
    return result;
  }

  Future<bool> unblock({required int userId, Function(Response)? success, Function(Response)? fail}) async{
    bool result = await UserBlockUserApi().unblock(blockId: userId, success: success, fail: fail);
    if(result){
      for(AfterUnblockedUserHandler handler in _unblockedHandlerList){
        handler.handle();
      }
    }
    return result;
  }
}

abstract class AfterBlockedUserHandler{

  Future handle();
}

abstract class AfterUnblockedUserHandler{

  Future handle();
}