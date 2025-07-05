
import "package:dio/dio.dart";
import "package:freego_flutter/model/user.dart";
import "http.dart";


class HttpComplain{

  static final dio = Dio();

  static final  complainAddUrl = URL_BASE_HOST + '/complain/add';

  static add(int type,int productType,int productId,String images,String content,OnDataResponse callback) async
  {
    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(complainAddUrl, data:{
      'type':type,
      'productType':productType,
      'productId':productId,
      'pics':images,
      'content':content
    },options: Options(headers:
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