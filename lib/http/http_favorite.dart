
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_util.dart';
import 'package:freego_flutter/model/favorite.dart';
import 'package:freego_flutter/util/storage.dart';
import 'package:freego_flutter/util/toast_util.dart';

class HttpFavorite {

  static Future<List<Favorite>?> getAll({Function(Response)? fail, Function(Response)? success}) async{
    String url = '/favorite/all';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取收藏失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<Favorite> list = [];
    for(dynamic item in response.data['data']){
      list.add(Favorite.fromJson(item));
    }
    list = toTree(list);
    return list;
  }

  static Future<List<Favorite>?> getAllDir({Function(Response)? fail, Function(Response)? success}) async{
    String url = '/favorite/all/dir';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取收藏目录失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<Favorite> list = [];
    for(dynamic item in response.data['data']){
      list.add(Favorite.fromJson(item));
    }
    list = toTree(list);
    return list;
  }

  static Future<Favorite?> createDir(int pid, String name, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/favorite/dir';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.post(url, data: {
      'pid': pid,
      'name': name
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('创建目录失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    Favorite favorite = Favorite.fromJson(response.data['data']);
    return favorite;
  }

  static Future<Favorite?> moidfyDir(int id, String name, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/favorite/der';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.put(url, data: {
      'id': id,
      'name': name
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('修改目录失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    Favorite favorite = Favorite.fromJson(response.data['data']);
    return favorite;
  }

  static Future<bool> remove(int id, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/favorite/$id';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.delete(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('删除目录失败');
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

  static Future<Favorite?> favorite(int pid, int targetId, int type, String name, String pic, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/favorite';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.post(url, data: {
      'pid': pid,
      'targetId': targetId,
      'type': type,
      'name': name,
      'pic': pic
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('收藏失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    Favorite favorite = Favorite.fromJson(response.data['data']);
    return favorite;
  }

  static Future<bool> unFavorite(int targetId, int type, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/favorite';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.delete(url, data: {
      'targetId': targetId,
      'type': type
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('取消收藏失败');
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

  static Future<bool> move(int id, int pid, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/favorite/move';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.put(url, data: {
      'id': id,
      'pid': pid
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('移动失败');
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

  static List<Favorite> toTree(List<Favorite> list){
    list.sort((f1, f2){
      if(f1.id < f2.id){
        return -1;
      }
      else if(f1.id > f2.id){
        return 1;
      }
      else{
        return 0;
      }
    });
    for(Favorite f in list){
      if(f.pid == null){
        continue;
      }
      int low = 0;
      int high = list.length - 1;
      while(low < high){
        int mid = low + (high - low) ~/ 2;
        if(list[mid].id == f.pid!){
          if(list[mid].children == null){
            list[mid].children = [];
          }
          list[mid].children!.add(f);
          break;
        }
        else if(list[mid].id > f.pid!){
          high = mid;
        }
        else{
          low = mid + 1;
        }
      }
    }
    List<Favorite> result = [];
    for(Favorite f in list){
      if(f.pid == 0){
        result.add(f);
      }
    }
    return result;
  }

}
