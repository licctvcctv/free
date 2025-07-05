
import "package:dio/dio.dart";
import "package:freego_flutter/components/travel/travel_common.dart";
import "package:freego_flutter/http/http_tool.dart";
import "package:freego_flutter/model/travel.dart";
import "package:freego_flutter/model/user.dart";
import "package:freego_flutter/util/pager.dart";
import "../model/order_customer.dart";
import "http.dart";

class HttpTravel{

  static searchTravel(String? keyword, {int limit = 10, int offset = 0, DateTime? endTime, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/travel/find';
    Pager<TravelModel>? pager = await HttpTool.get(url, {
      'keyword': keyword,
      'limit': limit,
      'offset': offset,
      'endTime': endTime
    }, (response){
      List<TravelModel> list = [];
      for(dynamic item in response.data['data']['list']){
        list.add(TravelModel.fromJson(item));
      }
      return Pager(list, response.data['data']['total']);
    }); 
    return pager;
  }

  static Future<Travel?> getById(int id, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/travel/detail';
    Travel? result = await HttpTool.get(url, {
      'id': id
    }, (response){
      return Travel.fromJson(response.data['data']);
    });
    return result;
  }

  static final dio = Dio();

  static final searchUrl = URL_BASE_HOST + '/travel/search';
  static final detailUrl =  URL_BASE_HOST + '/travel/detail';
  static final suitsUrl =  URL_BASE_HOST + '/travel/suits';
  static final suitPriceUrl = URL_BASE_HOST + '/travel/suitPrices';
  static final travelBookUrl = URL_BASE_HOST + '/travel/book';

  static search(String? keyword,int page, OnDataResponse callback) async
  {
    final response = await dio.post(searchUrl,data:{'keyword':keyword,'pageSize':8,'page':page},options: Options(headers: {'contentType': 'application/json'}));
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
    final response = await dio.get(detailUrl,queryParameters: {'id':id},options: Options(headers: {'contentType': 'application/json'}));
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
  static suits(int id,OnDataResponse callback) async
  {
    final response = await dio.get(suitsUrl,queryParameters: {'id':id},options: Options(headers: {'contentType': 'application/json'}));
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

  static getSuitPrices(int suitId,OnDataResponse callback) async
  {
    final response = await dio.get(suitPriceUrl,queryParameters: {'suitId':suitId},options: Options(headers: {'contentType': 'application/json'}));
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

  static book(int suitId,String day,int adultNum,int childNum, List<OrderCustomer> customerList,OnDataResponse callback) async
  {
    List<Map<String,dynamic>> customers = [];
    for(var i=0;i<customerList.length;i++)
    {
      customers.add({
        'name':customerList[i].name,
        'identityNum':customerList[i].identityNum,
        'phone':customerList[i].phone
      });
    }

    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(travelBookUrl,data:{'suitId':suitId,'adultNum':adultNum,'childNum':childNum,'day':day,'customerList':customers},options: Options(headers: {'contentType': 'application/json','token':userToken}));
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