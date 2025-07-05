
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/model/simple_map_poi.dart';

class GaodeHttp{

  GaodeHttp._internal();
  static final GaodeHttp _instance = GaodeHttp._internal();
  factory GaodeHttp(){
    return _instance;
  }

  static const mapApiKey = '050b2ade8500631a14557833b484a72a';
  static const Map innerTypes = {
    0: '100100|110000|050000',
    1: '100100|100101|100102|100103|100104|100105|100200|100201',
    2: '110000|110100|110101|110102|110103|110104|110105|110106|110200|110201|110202|110203|110204|110205|110206|110207|110208|110209|110210',
    3: '050000'
  };

  Future<List<SimpleHotel>?> nearHotelList({required double latitude, required double longitude, int radius = 10000, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = 'https://restapi.amap.com/v5/place/text';
    List<SimpleHotel>? result = await HttpTool.getRemote(url, {
      'key': mapApiKey,
      'location': '$latitude,$longitude',
      'types': innerTypes[1],
      'radius': radius,
      'page_size': pageSize,
      'page_num': pageNum,
      'show_fields': 'business,photos'
    }, (response){
      if(response.data['status'] != '1'){
        return null;
      }
      List<SimpleHotel> list = [];
      for(dynamic item in response.data['pois']){
        list.add(SimpleHotel.fromGaode(item));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<List<SimpleScenic>?> nearScenicList({required double latitude, required double longitude, int radius = 10000, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = 'https://restapi.amap.com/v5/place/text';
    List<SimpleScenic>? result = await HttpTool.getRemote(url, {
      'key': mapApiKey,
      'location': '$latitude,$longitude',
      'types': innerTypes[2],
      'radius': radius,
      'page_size': pageSize,
      'page_num': pageNum,
      'show_fields': 'business,photos'
    }, (response){
      if(response.data['status'] != '1'){
        return null;
      }
      List<SimpleScenic> list = [];
      for(dynamic item in response.data['pois']){
        list.add(SimpleScenic.fromGaode(item));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<List<SimpleRestaurant>?> nearRestaurantList({required double latitude, required double longitude, int radius = 10000, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = 'https://restapi.amap.com/v5/place/text';
    List<SimpleRestaurant>? result = await HttpTool.getRemote(url, {
      'key': mapApiKey,
      'location': '$latitude,$longitude',
      'types': innerTypes[3],
      'radius': radius,
      'page_size': pageSize,
      'page_num': pageNum,
      'show_fields': 'business,photos'
    }, (response){
      if(response.data['status'] != '1'){
        return null;
      }
      List<SimpleRestaurant> list = [];
      for(dynamic item in response.data['pois']){
        list.add(SimpleRestaurant.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }
}

class GaodeMapPoi implements SimpleMapPoi{
  @override
  String? source;
  @override
  String? outerId;
  @override
  int? id;

  @override
  String? name;
  @override  
  String? city;
  @override
  String? address;
  @override
  double? latitude;
  @override
  double? longitude;

  @override
  int? stars;
  @override
  double? score;
  @override
  String? cover;
  @override
  int? price;

  GaodeMapPoi.fromJson(dynamic json){
    source = 'gaode';
    outerId = json['id'];

    name = json['name'];
    city = json['cityname'];
    address = json['address'];

    String location = json['location'];
    var locationList = location.split(",");
    latitude = double.parse(locationList[1]);
    longitude = double.parse(locationList[0]);

    dynamic business = json['business'];
    if(business != null){
      if(business['rating'] is String){
        score = double.tryParse(business['rating']);
      }
      if(business['cost'] is String){
        double? priceDouble = double.tryParse(business['cost']);
        if(priceDouble != null){
          price = (priceDouble * 100).toInt();
        }
      }
    }
    
    dynamic photos = json['photos'];
    if(photos != null){
      List<String> photoList = [];
      for(dynamic item in photos){
        photoList.add(item['url']);
      }
      if(photoList.isNotEmpty){
        cover = photoList.first;
      }
    }
  }
}
