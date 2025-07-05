
import "package:dio/dio.dart";
import "package:freego_flutter/model/user.dart";
import "http.dart";


class HttpLike{

  static final dio = Dio();

  static final  moreVideoUrl = URL_BASE_HOST + '/video/recommend';

  static final videoSaveUrl = URL_BASE_HOST + '/videoManage/save';

  static more(String strategy,OnDataResponse callback) async
  {

    final response = await dio.post(moreVideoUrl, data:{"size":20,"strategy":strategy,"currentId":0},options: Options(headers: {'contentType': 'application/json'}));

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
      callback(true,response.data['data'],null,0);
      // if(response.data[''])
    }catch(e)
    {
      callback(false,null,e.toString(),0);
    }
  }
  static save(info,OnDataResponse callback) async
  {
    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(videoSaveUrl, data:info,options: Options(headers:
      {
        'contentType': 'application/json',
        'token':userToken
      }
    ));

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

      // if(response.data[''])
    }
    catch(e)
    {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);

  }



}