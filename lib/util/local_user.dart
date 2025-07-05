
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/storage.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);
final ProviderContainer container = ProviderContainer();

class LocalUser{

  static List<AfterLoginHandler> afterLoginHandlerList = [];
  static List<AfterLogoutHandler> afterLogoutHandlerList = [];

  static bool addAfterLoginHandler(AfterLoginHandler handler){
    if(afterLoginHandlerList.contains(handler)){
      return false;
    }
    afterLoginHandlerList.add(handler);
    return true;
  }

  static bool removeAfterLoginHandler(AfterLoginHandler handler){
    return afterLoginHandlerList.remove(handler);
  }

  static void initAfterLoginHandlerList(){
    afterLoginHandlerList = [];
  }

  static bool addAfterLogoutHandler(AfterLogoutHandler handler){
    if(afterLogoutHandlerList.contains(handler)){
      return false;
    }
    afterLogoutHandlerList.add(handler);
    return true;
  }

  static bool removeAfterLogoutHandler(AfterLogoutHandler handler){
    return afterLogoutHandlerList.remove(handler);
  }

  static void initAfterLogoutHandlerList(){
    afterLogoutHandlerList = [];
  }

  static void login(UserModel user){
    LocalUser.update(user);
    for(AfterLoginHandler handler in afterLoginHandlerList){
      handler.handle(user);
    }
  }

  static void logout(){
    UserModel? user = container.read(userProvider);
    LocalUser.clear();
    if(user != null){
      for(AfterLogoutHandler handler in afterLogoutHandlerList){
        handler.handle(user);
      }
    }
  }
  
  static void update(UserModel user){
    container.refresh(userProvider.notifier).update((state) => user);
    Storage.saveInfo('user_token', user.token);
    Storage.saveInfo('user_id', user.id);
    Storage.saveInfo('user_name', user.name);
    Storage.saveInfo('user_head', user.head);
    Storage.saveInfo('user_identity_type', user.identityType);
  }
  static void clear(){
    container.refresh(userProvider.notifier).update((state) => null);
    Storage.removeInfo('user_token');
    Storage.removeInfo('user_id');
    Storage.removeInfo('user_name');
    Storage.removeInfo('user_head');
    Storage.removeInfo('user_identity_type');
  }
  static UserModel? getUser(){
    UserModel? user = container.read(userProvider);
    return user;
  }
  static bool isLogined(){
    UserModel? user = container.read(userProvider);
    return user != null;
  }
  static Future<String?> getSavedToken() async{
    String? token = await Storage.readInfo<String>('user_token');
    return token;
  }
}

abstract class AfterLoginHandler{
  void handle(UserModel user);
}

abstract class AfterLogoutHandler{
  void handle(UserModel user);
}
