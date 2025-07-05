
import "package:dio/dio.dart";
import "package:freego_flutter/http/http_tool.dart";
import "package:freego_flutter/model/guide.dart";
import "package:freego_flutter/model/order.dart";
import "package:freego_flutter/model/user.dart";
import "package:freego_flutter/util/pager.dart";
import "http.dart";

class HttpGuide{

  static final dio = Dio();

  static const mapApiKey = "c856459376228b3235bc576eb267f0bf";
  static const mapNearSearchUrl = 'https://restapi.amap.com/v5/place/around';
  static const keywordSearchUrl = 'https://restapi.amap.com/v5/place/text';
  static const userSearchUrl = '${URL_BASE_HOST}/guide/userGuide';
  static const guideSaveUrl = '${URL_BASE_HOST}/guideManage/save';

  static Future<Order?> reward(int guideId, int amount, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/guide/reward';
    Order? order = await HttpTool.post(url, {
      'guideId': guideId,
      'amount': amount
    }, (response){
      Order order = Order.fromJson(response.data['data']);
      return order;
    }, fail: fail, success: success);
    return order;
  }

  static Future<Pager<GuideModel>?> getLatest(String keyword, {int limit = 10, int offset = 0, int? endId, Function(Response)? fail, Function(Response)? success}) async {
    const String url = '/guide/latest';
    Pager<GuideModel>? pager = await HttpTool.get(url, {
      'keyword': keyword,
      'limit': limit,
      'offset': offset,
      'endId': endId
    }, (response){
      List<GuideModel> list = [];
      for(dynamic item in response.data['data']['list']){
        list.add(GuideModel.fromJson(item));
      }
      int count = response.data['data']['total'];
      return Pager(list, count);
    });
    return pager;
  }

  static Future<GuideModel?> detail(int guideId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/guide/$guideId';
    GuideModel? guide = await HttpTool.get(url, {}, (response){
      GuideModel guide = GuideModel.fromJson(response.data['data']);
      return guide;
    });
    return guide;
  }

  static save(info,OnDataResponse callback) async {
    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(
      guideSaveUrl, 
      data:info,
      options: Options(
        headers: {
        'contentType': 'application/json',
        'token':userToken
       }
      )
    );

    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
    }
    catch(e) {
       callback(false,null,e.toString(),0);
       return;
    }
    callback(true,response.data['data'],null,0);

  }


  static userSearch(String? keyword,int userId,OnDataResponse callback) async{
    final response = await dio.post(userSearchUrl, data:{"pageSize":1000,"keyword":keyword,'userId':userId},options: Options(headers: {'contentType': 'application/json'}));

    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
    }
    catch(e) {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

}
