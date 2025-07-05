
import "package:dio/dio.dart";
import "package:freego_flutter/model/circle_article.dart";
import "package:freego_flutter/model/user.dart";
import "../model/circle_shop.dart";
import "http.dart";


class HttpCircleShop{

  static final dio = Dio();

  static final saveUrl = URL_BASE_HOST + '/circle/shop/save';

  static final detailUrlOfAuthor = URL_BASE_HOST + '/circle/shop/detailOfAuthor';

  static final detailUrl = URL_BASE_HOST + '/circle/shop/detail';

  static save(CircleShopModel shop, OnDataResponse callback) async
  {

    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(saveUrl,data:{
           'cid': shop.cid,
           'pics':shop.pics,
           'name':shop.name,
            'description':shop.description,
            'openCloseTime':shop.openCloseTime,
           'phone':shop.phone,
           'location':shop.location,
           'lng':shop.lng,
           'lat':shop.lat
        },
        options: Options(headers: {'contentType': 'application/json','token':userToken}));
    try{
      if(response.statusCode!=200)
      {
        throw "网络请求错误";
      }
      if(response.data==null)
      {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK)
      {
        throw response.data['message'];
      }

    }catch(e)
    {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

  static detail(int id,OnDataResponse callback) async
  {
    String? userToken = await UserModel.getUserToken();
    final response = await dio.get(detailUrl,queryParameters: {'id':id},options: Options(headers: {'contentType': 'application/json','token':userToken}));
    try{
      if(response.statusCode!=200)
      {
        throw "网络请求错误";
      }
      if(response.data==null)
      {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK)
      {
        throw response.data['message'];
      }
    }
    catch(e)
    {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);

  }

}