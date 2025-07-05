
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/http/http_user_like.dart';

class UserLikeUtil{

  static List<AfterUserLikeHandler> afterUserLikeHandlerList = [];
  static List<AfterUserUnlikeHandler> afterUserUnlikeHandlerList = [];

  static bool addAfterUserLikeHandler(AfterUserLikeHandler handler){
    if(afterUserLikeHandlerList.contains(handler)){
      return false;
    }
    afterUserLikeHandlerList.add(handler);
    return true;
  }

  static bool removeAfterUserLikeHandler(AfterUserLikeHandler handler){
    return afterUserLikeHandlerList.remove(handler);
  }

  static void initAfterUserLikeHandlerList(){
    afterUserLikeHandlerList = [];
  }

  static bool addAfterUserUnlikeHandler(AfterUserUnlikeHandler handler){
    if(afterUserUnlikeHandlerList.contains(handler)){
      return false;
    }
    afterUserUnlikeHandlerList.add(handler);
    return true;
  }

  static bool removeAfterUserUnlikeHandler(AfterUserUnlikeHandler handler){
    return afterUserUnlikeHandlerList.remove(handler);
  }

  static void initAfterUserUnlikeHandlerlist(){
    afterUserUnlikeHandlerList = [];
  }

  static Future<bool> like(int id, ProductType type) async{
    bool result = await HttpUserLike.like(id, type);
    if(result){
      for(AfterUserLikeHandler handler in afterUserLikeHandlerList){
        handler.handle(id, type);
      }
    }
    return result;
  }

  static Future<bool> unlike(int id, ProductType type) async{
    bool result = await HttpUserLike.unlike(id, type);
    if(result){
      for(AfterUserUnlikeHandler handler in afterUserUnlikeHandlerList){
        handler.handle(id, type);
      }
    }
    return result;
  }
}

abstract class AfterUserLikeHandler{

  void handle(int id, ProductType type);
}

abstract class AfterUserUnlikeHandler{

  void handle(int id, ProductType type);
}
