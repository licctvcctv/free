
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/util/toast_util.dart';

class HttpGaode{

  static const mapApiKey = '050b2ade8500631a14557833b484a72a';
  static const Map innerTypes = {
      0: '120000|150000|070000|100100|110000|050000',
      1: '100100|100101|100102|100103|100104|100105|100200|100201',
      2: '110000|110100|110101|110102|110103|110104|110105|110106|110200|110201|110202|110203|110204|110205|110206|110207|110208|110209|110210',
      3: '050000'
  };

  static Future<List<MapPoiModel>?> searchNearPoint(double lat, double lng, {int? type, int page = 1, int pageSize = 10, double radius = 50000, String? keyword, Function(Response)? fail, Function(Response)? success}) async{
    const String url = 'https://restapi.amap.com/v5/place/around';
    List<MapPoiModel>? list = await HttpTool.getRemote(url, {
      'key': mapApiKey,
      'location': '$lat,$lng',
      'types': type == null ? null : innerTypes[type],
      'radius': radius,
      'sortrule': 'distance',
      'page_size': pageSize,
      'page_num': page,
      'show_fields': 'business,photos'
    }, (response){
      if(response.data['status'] != '1'){
        return null;
      }
      List<MapPoiModel> list = [];
      for(dynamic item in response.data['pois']){
        list.add(MapPoiModel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<List<MapPoiModel>?> searchByKeyword(String keyword, {int? type, int page = 1, int pageSize = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = 'https://restapi.amap.com/v5/place/text';
    List<MapPoiModel>? list = await HttpTool.getRemote(url, {
      'key': mapApiKey,
      'keywords': keyword,
      'types': type == null ? null : innerTypes[type],
      'page_size': pageSize,
      'page_num': page,
      'show_fields': 'business,photos'
    }, (response){
      if(response.data['status'] != '1'){
        return null;
      }
      List<MapPoiModel> list = [];
      for(dynamic item in response.data['pois']){
        list.add(MapPoiModel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<GeoAddress?> regeo(double lat, double lng, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = 'https://restapi.amap.com/v3/geocode/regeo';
    const int radius = 1000;
    GeoAddress? address = await HttpTool.getRemote(url, {
      'key': mapApiKey,
      'location': '$lng,$lat',
      'radius': radius,
    }, (response){
      if(response.data['status'] != '1'){
        return null;
      }
      dynamic json = response.data['regeocode']['addressComponent'];
      GeoAddress address = GeoAddress(
        province: json['province'],
        city: json['city'] is String ? json['city'] : '', 
        district: json['district'],
        township: json['township'], 
        street: json['streetNumber']['street'] is String ? json['streetNumber']['street'] : null, 
        number: json['streetNumber']['number'] is String ? json['streetNumber']['number'] : null, 
        building: json['building']['name'] is String ? json['building']['name'] : null
      );
      if(address.city == ''){
        if(['北京市', '上海市', '天津市', '重庆市'].contains(address.province)){
          address.city = address.province;
        }
        else{
          address.city = address.district;
        }
      }
      return address;
    }, fail: fail, success: success);
    return address;
  }

  static Future<List<MapPoiModel>?> getNearAddress(double lat, double lng, {String? keywords, int? type, int page = 1, int pageSize = 20, double radius = 10000, Function(Response)? success, Function(Response)? fail}) async{
    const String url = 'https://restapi.amap.com/v5/place/around';
    List<MapPoiModel>? list = await HttpTool.getRemote(url, {
      'key': mapApiKey,
      'location': '$lat,$lng',
      'radius': radius,
      'page_size': pageSize,
      'page_num': page,
      'keywords': keywords,
      'show_fields': 'business,photos',
      'types': type == null ? '010000|050000|060000|070000|080000|100000|110000|120000|130000|140000|150000' : innerTypes[type]
    }, (response){
      if(response.data['status'] != '1'){
        return null;
      }
      List<MapPoiModel> list = [];
      for(dynamic item in response.data['pois']){
        list.add(MapPoiModel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }
}

class GeoAddress{
  String province;
  String city;
  String district;
  String township;
  String? street;
  String? number;
  String? building;

  GeoAddress({required this.province, required this.city, required this.district, required this.township, required this.street, required this.number, required this.building});
  
  @override
  String toString(){
    return province + city + district + township + (street ?? '') + (number ?? '') + (building ?? '');
  }
}

class SimplePoi{
  double? latitude;
  double? longitude;
  String? address;
  String? city;

  SimplePoi({required this.latitude, required this.longitude, required this.address});
  SimplePoi.fromJson(dynamic json){
    address = json['address'];
    city = json['cityname'];
    if(json['location'] is String){
      List<dynamic> list = (json['location'] as String).split(',');
      if(list.length == 2){
        longitude = double.parse(list[0]);
        latitude = double.parse(list[1]);
      }
    }
  }
}
