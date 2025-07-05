
import "package:dio/dio.dart";
import "package:freego_flutter/model/map_poi.dart";
import "http.dart";

class HttpAmap{

  static final dio = Dio();
  static const mapNearSearchUrl = 'https://restapi.amap.com/v5/place/around';
  static const keywordSearchUrl = 'https://restapi.amap.com/v5/place/text';
  static const addressFromLatlng = 'https://restapi.amap.com/v3/geocode/regeo';
  static const mapApiKey = "050b2ade8500631a14557833b484a72a";

  /*
     pointType:1酒店，2景点，3美食
   */

  static const POINT_TYPE_HOTEL = 1;
  static const POINT_TYPE_SPOT = 2;
  static const POINT_TYPE_RESTAURANT = 3;

  static Future<List<MapPoiModel>?> searchNearPoint(double lat, double lng, int pointType, int page, OnDataResponse? callback) async {
    var types={
      1: "100100|100101|100102|100103|100104|100105|100200|100201",
      2: "110000|110100|110101|110102|110103|110104|110105|110106|110200|110201|110202|110203|110204|110205|110206|110207|110208|110209|110210",
      3: "050000"
    };
    final response = await dio.get(mapNearSearchUrl, options: Options(headers: {'contentType': 'application/json'}), queryParameters: {
      "key": mapApiKey,
      "location": "$lat,$lng",
      "types": types[pointType],
      "radius": 50000,
      "page_size": 25,
      "page_num": page,
      'show_fields': 'business,photos'
    });
    try {
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['infocode'] != "10000") {
        throw "请求失败";
      }
      if(callback != null){
        callback(true,response.data['pois'],null,0);
      }
      List<MapPoiModel> list = [];
      for(dynamic item in response.data['pois']){
        list.add(MapPoiModel.fromJson(item));
      }
      return list;
    } catch(e) {
      if(callback != null){
        callback(false,null,e.toString(),0);
      }
      return null;
    }
  }

  static searchPoint(String keyword) async
  {
    final response = await dio.get(keywordSearchUrl, options: Options(headers: {'contentType': 'application/json'}), queryParameters: {
      "key":mapApiKey,
      "keywords":keyword
    });
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['infocode'] != "10000") {
        throw "请求失败";
      }
      return response.data['pois'];
      // if(response.data[''])
    } catch(e) {
      // print(response.data['info']);
      return null;
    }
  }

  static getAddressFromLatlng(double lng,double lat) async {
    final response = await dio.get(addressFromLatlng,options: Options(headers: {'contentType': 'application/json'}),queryParameters: {
      "key":mapApiKey,
      "location":"$lng,$lat"
    });
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['infocode'] != "10000") {
        throw "请求失败";
      }
      return response.data['regeocode'];
      // if(response.data[''])
    } catch(e) {
      // print(response.data['info']);
      return null;
    }
  }

}
