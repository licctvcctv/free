
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_http.dart';

class UserFavoriteUtil{

  UserFavoriteUtil._internal();
  static final UserFavoriteUtil _instance = UserFavoriteUtil._internal();
  factory UserFavoriteUtil(){
    return _instance;
  }

  List<AfterUserFavoriteHandler> favoriteHandlerList = [];
  List<AfterUserUnFavoriteHandler> unFavoriteHandlerList = [];

  bool addFavoriteHandler(AfterUserFavoriteHandler handler){
    if(favoriteHandlerList.contains(handler)){
      return false;
    }
    favoriteHandlerList.add(handler);
    return true;
  }
  bool removeFavoriteHandler(AfterUserFavoriteHandler handler){
    return favoriteHandlerList.remove(handler);
  }

  bool addUnFavoriteHandler(AfterUserUnFavoriteHandler handler){
    if(unFavoriteHandlerList.contains(handler)){
      return false;
    }
    unFavoriteHandlerList.add(handler);
    return true;
  }
  bool removeUnFavoriteHandler(AfterUserUnFavoriteHandler handler){
    return unFavoriteHandlerList.remove(handler);
  }

  Future<bool> favorite({required int productId, required ProductType type}) async{
    bool result = await UserFavoriteHttp().favorite(productId: productId, type: type);
    if(result){
      for(AfterUserFavoriteHandler handler in favoriteHandlerList){
        handler.handle(productId, type);
      }
    }
    return result;
  }

  Future<bool> unFavorite({required int productId, required ProductType type}) async{
    bool result = await UserFavoriteHttp().unfavorite(productId: productId, type: type);
    if(result){
      for(AfterUserUnFavoriteHandler handler in unFavoriteHandlerList){
        handler.handle(productId, type);
      }
    }
    return result;
  }
}

abstract class AfterUserFavoriteHandler{
  void handle(int productId, ProductType type);
}

abstract class AfterUserUnFavoriteHandler{
  void handle(int productId, ProductType type);
}
