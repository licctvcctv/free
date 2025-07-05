
import 'dart:async';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/config/const_config.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/screen_size.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';

class CommonAmapPage extends ConsumerStatefulWidget{
  const CommonAmapPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return CommonAmapState();
  }

}

class CommonAmapState extends ConsumerState<CommonAmapPage>{

  final CameraPosition defaultPosition = const CameraPosition(target: LatLng(39.909187, 116.397451), zoom: 10);
  late AMapController controller;
  AMapFlutterLocation location = AMapFlutterLocation();
  LatLng? position;
  Set<Marker> markerSet = {};
  Marker? marker;
  LatLng? choosePos;
  String? chooseInfo;

  Future getPermission(){
    return PermissionUtil().requestPermission(context: context, permission: Permission.location, info: '希望获取位置权限用于标记您所在位置');
  }

  void locate(){
    location.onLocationChanged().listen((result) {
      var latitude = result['latitude'];
      if(latitude is String){
        latitude = double.tryParse(latitude);
      }
      var longitude = result['longitude'];
      if(longitude is String){
        longitude = double.tryParse(longitude);
      }
      if(latitude != null && longitude != null){
        position = LatLng(latitude as double, longitude as double);
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: position!)));
      }
      location.stopLocation();
    });
    location.startLocation();
  }

  @override
  void dispose(){
    location.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic args = ModalRoute.of(context)?.settings.arguments;
    State? referer = args?['referer'];
    bool? readOnly = args?['readOnly'];
    double? latitude = args?['latitude'];
    double? longitude = args?['longitude'];
    double? zoom = args?['zoom'];
    String? info = args?['info'];

    if(position == null){
      if(latitude == null || longitude == null){
        getPermission();
        locate();
      } else{
        position = LatLng(latitude, longitude);
        chooseInfo = info!;
        markerSet.clear();
        marker = Marker(position: position!);
        markerSet.add(marker!);
      }
    }

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Stack(
        children: [
          Stack(
            children: [
              AMapWidget(
                apiKey: const AMapApiKey(androidKey:ConstConfig.amapApiKeyOfAndroid, iosKey: ConstConfig.amapApiKeyOfIOS),
                privacyStatement: const AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true),
                myLocationStyleOptions: MyLocationStyleOptions(true),
                onMapCreated: (controllerParam) {
                  controller = controllerParam;
                },
                initialCameraPosition: position != null ? CameraPosition(target: position!, zoom: zoom ?? 10) : defaultPosition,
                touchPoiEnabled: readOnly != null ? !readOnly : true,
                onPoiTouched: (AMapPoi poi){
                  if(poi.latLng != null){
                    setState(() {
                      choosePos = poi.latLng;
                      chooseInfo = poi.name;
                      markerSet.clear();
                      marker = Marker(position: choosePos!);
                      markerSet.add(marker!);
                    });
                  }
                },
                markers: markerSet,
                buildingsEnabled: false,
                labelsEnabled: true,
                tiltGesturesEnabled: false,
                mapType: MapType.navi,
              ),
              const Positioned(
                left: 0,
                bottom: 0,
                child: Text('高德地图', style: TextStyle(color: Color.fromRGBO(78, 89, 105, 0.6))),
              )
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: realScreenWidth,
              height: 48,
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0x99, 0x99, 0x99, 0.6),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                  const Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('选择位置', style: TextStyle(color: Colors.white, fontSize: 16),),
                    )
                  ),
                  const SizedBox(
                    width: 48,
                  )
                ]
              ),
              
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: realScreenWidth,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey, width: 1, style: BorderStyle.solid))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      alignment: Alignment.centerLeft,
                      child: Text(chooseInfo ?? '请选择位置'),
                    ),
                  ),
                  Visibility(
                    visible: readOnly != null ? !readOnly : true,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: (){
                          if(choosePos != null && chooseInfo != null){
                            Navigator.of(context).pop({
                              'lat': choosePos!.latitude,
                              'lng': choosePos!.longitude,
                              'info': chooseInfo
                            });
                            if(referer != null && referer is Locatable){
                              (referer as Locatable).locateCallback(longitude: choosePos!.longitude, latitude: choosePos!.latitude, info: chooseInfo!);
                            }
                          }
                          else{
                            ToastUtil.customHint(context, '请选择位置');
                          }
                        },
                        child: const Text('确定'),
                      ),
                    ),
                  ),
                ],
              )
            ),
          )
        ],
      ),
    );
  }

}

abstract class Locatable{

  void locateCallback({required double longitude, required double latitude, required String info});
}
