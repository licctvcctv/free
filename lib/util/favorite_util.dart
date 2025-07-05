
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/favorite_dir_choose.dart';
import 'package:freego_flutter/http/http_favorite.dart';
import 'package:freego_flutter/model/favorite.dart';
import 'package:freego_flutter/util/dialog_util.dart';

class FavoriteUtil{

  static List<AfterFavoriteHandler> afterFavoriteHandlerList = [];
  static List<AfterUnfavoriteHandler> afterUnfavoriteHandlerList = [];
  static List<AfterCreateDirHandler> afterCreateDirHandlerList = [];
  static List<AfterRemoveDirHandler> afterRemoveDirHandlerList = [];

  static bool addAfterFavoriteHandler(AfterFavoriteHandler handler){
    if(afterFavoriteHandlerList.contains(handler)){
      return false;
    }
    afterFavoriteHandlerList.add(handler);
    return true;
  }

  static bool removeAfterFavoriteHandler(AfterFavoriteHandler handler){
    return afterFavoriteHandlerList.remove(handler);
  }

  static void initAfterFavoriteHandlerList(){
    afterFavoriteHandlerList = [];
  }

  static bool addAfterUnfavoriteHandler(AfterUnfavoriteHandler handler){
    if(afterUnfavoriteHandlerList.contains(handler)){
      return false;
    }
    afterUnfavoriteHandlerList.add(handler);
    return true;
  }

  static bool removeAfterUnfavoriteHandler(AfterUnfavoriteHandler handler){
    return afterUnfavoriteHandlerList.remove(handler);
  }

  static void initAfterUnfavoriteHandlerList(){
    afterUnfavoriteHandlerList = [];
  }

  static bool addAfterCreateDirHandler(AfterCreateDirHandler handler){
    if(afterCreateDirHandlerList.contains(handler)){
      return false;
    }
    afterCreateDirHandlerList.add(handler);
    return true;
  }

  static bool removeAfterCreateDirHandler(AfterCreateDirHandler handler){
    return afterCreateDirHandlerList.remove(handler);
  }

  static void initAfterCreateDirHandlerList(){
    afterCreateDirHandlerList = [];
  }

  static bool addAfterRemoveDirHandler(AfterRemoveDirHandler handler){
    if(afterRemoveDirHandlerList.contains(handler)){
      return false;
    }
    afterRemoveDirHandlerList.add(handler);
    return true;
  }

  static bool removeAfterRemoveDirHandler(AfterRemoveDirHandler handler){
    return afterRemoveDirHandlerList.remove(handler);
  }

  static void initAfterRemoveDirHandlerList(){
    afterRemoveDirHandlerList = [];
  }

  static Future<Favorite?> createDir(int pid, String name) async{
    Favorite? result = await HttpFavorite.createDir(pid, name);
    if(result == null){
      return null;
    }
    for(AfterCreateDirHandler handler in afterCreateDirHandlerList){
      handler.handle(result);
    }
    return result;
  }

  static Future<bool> removeDir(Favorite favorite) async{
    if(favorite.productType != FavoriteType.dir.getNum()){
      return false;
    }
    bool result = await HttpFavorite.remove(favorite.id);
    if(!result){
      return false;
    }
    List<Favorite> toRemoveList = [];
    _fillToRemoveList(toRemoveList, favorite);
    toRemoveList.forEach((element) {
      for(AfterUnfavoriteHandler handler in afterUnfavoriteHandlerList){
        handler.handle(element.productId!, element.productType!);
      }
    });
    for(AfterRemoveDirHandler handler in afterRemoveDirHandlerList){
      handler.handle(favorite);
    }
    return true;
  }

  static _fillToRemoveList(List<Favorite> result, Favorite item){
    item.children?.forEach((element) {
      _fillToRemoveList(result, element);
    });
    if(item.productType != FavoriteType.dir.getNum()){
      result.add(item);
    }
  }

  static Future<Favorite?> favorite(int pid, int id, int type, String name, String pic) async{
    Favorite? favorite = await HttpFavorite.favorite(pid, id, type, name, pic);
    if(favorite == null){
      return null;
    }
    for(AfterFavoriteHandler handler in afterFavoriteHandlerList){
      handler.handle(favorite);
    }
    return favorite;
  }

  static Future<bool> unfavorite(int id, int type) async{
    bool result = await HttpFavorite.unFavorite(id, type);
    if(!result){
      return false;
    }
    for(AfterUnfavoriteHandler handler in afterUnfavoriteHandlerList){
      handler.handle(id, type);
    }
    return true;
  }

  static Future<List<Favorite>?> getAllDir() async{
    return await HttpFavorite.getAllDir();
  }

  static Future<int?> chooseDir(BuildContext context, {List<Favorite>? list, Favorite? current}) async{
    List<Favorite>? result;
    result = await getStack(context, list: list, current: current);
    if(result == null){
      return null;
    }
    if(result.isEmpty){
      return 0;
    }
    return result.last.id;
  }

  static Future<List<Favorite>?> getStack(BuildContext context, {List<Favorite>? list, Favorite? current}) async{
    list ??= await HttpFavorite.getAll();
    List<Favorite>? result;
    if(context.mounted){
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),  
        builder: (context){
          double height = MediaQuery.of(context).size.height * 0.6;
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            height: height,
            width: MediaQuery.of(context).size.width,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            child: FavoriteDirChooseWidget(
              list!, 
              current: current,
              onSubmit: (stack){
                result = stack;
                Navigator.of(context).pop();
              }, 
              onRemove: (favorite) async{
                bool confirm = await DialogUtil.showConfirm(context, info: '确认要删除？');
                bool success = false;
                if(confirm){
                  success = await FavoriteUtil.removeDir(favorite);
                }
                return success;
              },
            )
          );
        }
      );
    }
    return result;
  }
}

abstract class AfterFavoriteHandler{

  void handle(Favorite favorite);
}

abstract class AfterUnfavoriteHandler{

  void handle(int id, int type);
}

abstract class AfterCreateDirHandler{

  void handle(Favorite favorite);
}

abstract class AfterRemoveDirHandler{

  void handle(Favorite favorite);
}
