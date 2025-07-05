
import "package:dio/dio.dart";
import "package:freego_flutter/model/user.dart";
import "http.dart";


class HttpKeyword{

  static final dio = Dio();
  static final  hotKeywordUrl = URL_BASE_HOST + '/keyword/hot';


  static getHotSearch(OnDataResponse callback) async
  {

      final response = await dio.get(hotKeywordUrl,options: Options(headers: {'contentType': 'application/json'}));
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
        print(response.data['data']);
      }catch(e)
      {
        callback(false,null,e.toString(),0);
        return;
      }

      callback(true,response.data['data'],null,0);
  }


}