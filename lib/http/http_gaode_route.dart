
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:freego_flutter/http/http_gaode.dart';
import 'package:freego_flutter/http/http_tool.dart';

class HttpGaodeRoute{

  HttpGaodeRoute._internal();
  static final HttpGaodeRoute _instance = HttpGaodeRoute._internal();
  factory HttpGaodeRoute(){
    return _instance;
  }

  Future<List<LatLng>?> getDrivingRoute({required double originLat, required double originLng, required double destLat, required double destLng}) async{
    const url = 'https://restapi.amap.com/v5/direction/driving';
    List<LatLng>? result = await HttpTool.getRemote(url, {
      'key': HttpGaode.mapApiKey,
      'origin': '$originLng,$originLat',
      'destination': '$destLng,$destLat',
      'strategy': 2,
      'show_fields': 'polyline'
    }, (response){
      if(response.data['status'] != '1'){
        return null;
      }
      dynamic route = response.data['route'];
      if(route == null){
        return null;
      }
      List<LatLng> list = [];
      for(dynamic path in route['paths']){
        for(dynamic step in path['steps']){
          String polyline = step['polyline'];
          List<String> points = polyline.split(';');
          for(String str in points){
            List<String> posList = str.split(',');
            double? latitude;
            double? longitude;
            if(posList.length > 1){
              latitude = double.tryParse(posList[1]);
              longitude = double.tryParse(posList.first);
            }
            if(latitude != null && longitude != null){
              LatLng latLng = LatLng(latitude, longitude);
              list.add(latLng);
            }
          }
        }
      }
      return list;
    });
    return result;
  }

  Future<List<LatLng>?> getWalkingRoute({required double originLat, required double originLng, required double destLat, required double destLng}) async{
    const url = 'https://restapi.amap.com/v5/direction/walking';
    List<LatLng>? result = await HttpTool.getRemote(url, {
      'key': HttpGaode.mapApiKey,
      'origin': '$originLng,$originLat',
      'destination': '$destLng,$destLat',
      'strategy': 2,
      'show_fields': 'polyline'
    }, (response){
      if(response.data['status'] != '1'){
        return null;
      }
      dynamic route = response.data['route'];
      if(route == null){
        return null;
      }
      List<LatLng> list = [];
      for(dynamic path in route['paths']){
        for(dynamic step in path['steps']){
          String polyline = step['polyline'];
          List<String> points = polyline.split(';');
          for(String str in points){
            List<String> posList = str.split(',');
            double? latitude;
            double? longitude;
            if(posList.length > 1){
              latitude = double.tryParse(posList[1]);
              longitude = double.tryParse(posList.first);
            }
            if(latitude != null && longitude != null){
              LatLng latLng = LatLng(latitude, longitude);
              list.add(latLng);
            }
          }
        }
      }
      return list;
    });
    return result;
  }
}
