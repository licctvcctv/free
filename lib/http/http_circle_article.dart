
import "package:dio/dio.dart";
import "package:freego_flutter/model/circle_article.dart";
import "package:freego_flutter/model/user.dart";
import "http.dart";


class HttpCircleArticle{

  static final dio = Dio();

  static final saveUrl = URL_BASE_HOST + '/circle/article/save';

  static final detailUrlOfAuthor = URL_BASE_HOST + '/circle/article/detailOfAuthor';

  static final detailUrl = URL_BASE_HOST + '/circle/article/detail';

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


  static save(CircleArticleModel article, OnDataResponse callback) async
  {

    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(saveUrl,data:{
           'cid': article.cid,
           'pics':article.pics,
           'title':article.title,
            'content':article.content,
            'tags':article.tags,
           'location':article.location,
           'lng':article.lng,
           'lat':article.lat,
           'status':article.status
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

}