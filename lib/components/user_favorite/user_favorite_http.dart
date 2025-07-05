
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_model.dart';
import 'package:freego_flutter/http/http_tool.dart';

class UserFavoriteHttp{

  UserFavoriteHttp._internal();
  static final UserFavoriteHttp _instance = UserFavoriteHttp._internal();
  factory UserFavoriteHttp(){
    return _instance;
  }

  Future<bool> favorite({required int productId, required ProductType type, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/favorite';
    bool? result = await HttpTool.post(url, {
      'productId': productId,
      'productType': type.getNum()
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<bool> unfavorite({required int productId, required ProductType type, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/favorite';
    bool? result = await HttpTool.delete(url, {
      'productId': productId,
      'productType': type.getNum()
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<List<UserFavorite>?> list({required ProductType type, int limit = 10, int? maxId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/favorite/list';
    List<UserFavorite>? tmpList = await HttpTool.get(url, {
      'productType': type.getNum(),
      'limit': limit,
      'maxId': maxId
    }, (response){
      List<UserFavorite> list = [];
      for(dynamic item in response.data['data']){
        list.add(UserFavorite.fromJson(item));
      }
      return list;
    });
    return tmpList;
  }
  
}
